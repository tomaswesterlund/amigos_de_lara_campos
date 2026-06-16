import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:lara_demo/components/acorn_component.dart';
import 'package:lara_demo/components/branch_component.dart';
import 'package:lara_demo/components/cloud_component.dart';
import 'package:lara_demo/components/coin_component.dart';
import 'package:lara_demo/components/pop_text_component.dart';
import 'package:lara_demo/components/hearts/red_heart_component.dart';
import 'package:lara_demo/components/honeycomb_component.dart';
import 'package:lara_demo/components/lilypad_component.dart';
import 'package:lara_demo/components/pinecone_component.dart';
import 'package:lara_demo/components/rhenne_player_character_component.dart';
import 'package:lara_demo/components/sky_layer_component.dart';
import 'package:lara_demo/components/water_layer_component.dart';
import 'package:lara_demo/components/wave_indicator_component.dart';
import 'package:lara_demo/widgets/falling_lane_item.dart';
import 'package:lara_demo/core/lara_audio.dart';
import 'package:lara_demo/core/lara_base_game.dart';
import 'package:lara_demo/core/lara_theme.dart';

class RhenneJumpsGame extends LaraBaseGame with TapCallbacks, HasCollisionDetection {
  RhenneJumpsGame() : super(gradient: LaraGradients.pond, bgm: LaraBgm.rhenne);

  double elapsedTime = 0.0;
  late final RhennePlayerCharacterComponent _rhenne;

  final List<CloudComponent> _clouds = [];
  final List<LilypadComponent> _pads = [];
  int _currentLaneIndex = 1;
  LilypadComponent? _lastLandedPad;

  bool isGameOver = false;

  int currentWave = 1;
  double baseItemSpeed = 200.0;
  final double speedIncreasePerWave = 25.0;
  final Random _random = Random();

  final List<FallingLaneItem> spawnItems = [];

  @override
  Future onLoad() async {
    super.onLoad();

    await add(SkyLayerComponent(size: size));
    await add(WaterLayerComponent(size: Vector2(25, 25)));

    for (var i = 0; i < 3; i++) {
      final width = size.x / 3;
      final pad = LilypadComponent(size: Vector2(100, 100));
      pad.anchor = Anchor.center;
      pad.position = Vector2((width * i) + (width / 2), size.y - 150);
      _pads.add(pad);
      await add(pad);
    }

    _generateWaveItems();

    _rhenne = RhennePlayerCharacterComponent(
      onCollisionStarted: (player, other) {
        if (isGameOver) return;

        if (other is LilypadComponent) {
          if (_lastLandedPad != null && other == _lastLandedPad) return;
          other.startRippleAnimation();
          _lastLandedPad = other;
        }

        if (other is AcornComponent ||
            other is BranchComponent ||
            other is HoneycombComponent ||
            other is PineconeComponent) {
          isGameOver = true;

          LaraAudio.stopBgm();
          LaraAudio.playSfx(LaraSfx.miss);

          _rhenne.setAnimation(
            RhennePlayerCharacterState.die,
            onComplete: () {
              super.showGameOver(message: '¡Muy bien!', onRestart: () {}, onHome: () {});
              pauseEngine();
            },
          );
        }

        if (other is CoinComponent || other is RedHeartComponent) {
          other.removeFromParent();

          if (other is CoinComponent) {
            LaraAudio.playSfx(LaraSfx.coin);
            final pop = PopTextComponent(showCoin: true, label: "+1 moneda", startPosition: other.position);
            add(pop);
            super.addCoins(1);
          } else if (other is RedHeartComponent) {
            LaraAudio.playSfx(LaraSfx.hitGood);
            final pop = PopTextComponent(showCoin: false, label: "+3 puntos", startPosition: other.position);
            add(pop);
            super.addPoints(3);
          }
        }
      },
      size: Vector2(75, 75),
    );

    _rhenne.anchor = Anchor.center;
    _setupPlayerInitialPosition();
    await add(_rhenne);

    _currentLaneIndex = 1;
    _showWaveAnnouncement();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    elapsedTime += dt;

    // Clouds
    _clouds.removeWhere((cloud) => cloud.isRemoved || !cloud.isMounted);
    _spawnClouds();

    // Spawn falling targets safely mapping items dynamic configurations
    final itemsToSpawn = spawnItems.where((i) => !i.isProcessed && i.spawnTimeInSeconds <= elapsedTime);
    for (var item in itemsToSpawn) {
      item.isProcessed = true;
      PositionComponent fallingObject;

      switch (item.type) {
        case FallingLaneItemTypes.coin:
          fallingObject = CoinComponent(size: Vector2(75, 75));
          break;
        case FallingLaneItemTypes.acorn:
          fallingObject = AcornComponent(size: Vector2(40, 40));
          break;
        case FallingLaneItemTypes.branch:
          fallingObject = BranchComponent(size: Vector2(40, 40));
          break;
        case FallingLaneItemTypes.honeycomb:
          fallingObject = HoneycombComponent(size: Vector2(40, 40));
          break;
        case FallingLaneItemTypes.pinecone:
          fallingObject = PineconeComponent(size: Vector2(40, 40));
          break;
        case FallingLaneItemTypes.redHeart:
          fallingObject = RedHeartComponent(size: Vector2(60, 60));
          break;
        default:
          continue;
      }

      fallingObject.anchor = Anchor.center;
      fallingObject.position = Vector2(_pads[item.lane - 1].x, -50);
      add(fallingObject);
    }

    final double currentSpeed = baseItemSpeed + ((currentWave - 1) * speedIncreasePerWave);

    // Query active falling objects inside Flame's native tracking tree
    final activeItems = children
        .where(
          (c) =>
              c is CoinComponent ||
              c is AcornComponent ||
              c is BranchComponent ||
              c is HoneycombComponent ||
              c is PineconeComponent ||
              c is RedHeartComponent,
        )
        .cast<PositionComponent>();

    for (var item in activeItems) {
      item.position.y += currentSpeed * dt;

      // Safe clean up as soon as bounds pass screen constraints
      if (item.position.y > size.y + 100) {
        item.removeFromParent();
      }
    }

    // Process next stage timelines cleanly without list manipulation bugs
    final allItemsSpawned = spawnItems.every((item) => item.isProcessed);
    if (allItemsSpawned && activeItems.isEmpty) {
      currentWave++;
      elapsedTime = 0.0;
      _generateWaveItems();
      _showWaveAnnouncement();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isGameOver || _rhenne.isJumping) return;

    final tapX = event.localPosition.x;
    final playerX = _rhenne.position.x;

    if (tapX < playerX) {
      if (_currentLaneIndex > 0) {
        _currentLaneIndex--;
        _triggerJump();
      }
    } else {
      if (_currentLaneIndex < 2) {
        _currentLaneIndex++;
        _triggerJump();
      }
    }
  }

  void _generateWaveItems() {
    spawnItems.clear();

    // --- 1.0 to 9.0 Seconds (1.5s gaps) ---
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 1, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 1, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 1, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 2.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 2.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 2.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 4, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 4, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 4, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 5.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 5.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 5.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 7, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 7, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.pinecone, spawnTimeInSeconds: 7, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 9, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.coin, spawnTimeInSeconds: 9, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 9, lane: 3));

    // --- 11.0 to 19.5 Seconds ---
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 11, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 11, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 11, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 12.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 12.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 12.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.pinecone, spawnTimeInSeconds: 14.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 14.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 14.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 16, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 16, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 16, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 18, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 18, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 18, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 19.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 19.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.pinecone, spawnTimeInSeconds: 19.5, lane: 3));

    // --- 21.0 to 29.5 Seconds ---
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 21, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 21, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 21, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 23, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 23, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 23, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 24.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.coin, spawnTimeInSeconds: 24.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 24.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.pinecone, spawnTimeInSeconds: 26, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.pinecone, spawnTimeInSeconds: 26, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 26, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 28, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 28, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 28, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 29.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 29.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 29.5, lane: 3));

    // --- 31.0 to 40.0 Seconds ---
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 31, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 31, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 31, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.pinecone, spawnTimeInSeconds: 32.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.coin, spawnTimeInSeconds: 32.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 32.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 34.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 34.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 34.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 36, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 36, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 36, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 38, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.pinecone, spawnTimeInSeconds: 38, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 38, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 40, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 40, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 40, lane: 3));

    // --- 41.5 to 50.0 Seconds ---
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 41.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.coin, spawnTimeInSeconds: 41.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 41.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 43, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 43, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 43, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 44.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.pinecone, spawnTimeInSeconds: 44.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 44.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 46.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 46.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 46.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 48, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 48, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.pinecone, spawnTimeInSeconds: 48, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 50, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 50, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 50, lane: 3));

    // --- 51.5 to 60.0 Seconds ---
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 51.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 51.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.pinecone, spawnTimeInSeconds: 51.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 53, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 53, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 53, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.branch, spawnTimeInSeconds: 54.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 54.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 54.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 56.5, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.pinecone, spawnTimeInSeconds: 56.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 56.5, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.honeycomb, spawnTimeInSeconds: 58, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.acorn, spawnTimeInSeconds: 58, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 58, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.coin, spawnTimeInSeconds: 60, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 60, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.coin, spawnTimeInSeconds: 60, lane: 3));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 61.0, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 61.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 62.0, lane: 3));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 62.5, lane: 2));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 63.0, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 63.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 64.0, lane: 3));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 64.5, lane: 2));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 65.0, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 65.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 66.0, lane: 3));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 66.5, lane: 2));

    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 67.0, lane: 1));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 67.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 68.0, lane: 3));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 68.5, lane: 2));
    spawnItems.add(FallingLaneItem(type: FallingLaneItemTypes.redHeart, spawnTimeInSeconds: 69.0, lane: 1));
  }

  void _spawnClouds() {
    if (_clouds.length >= 3) return;

    final cloudWidth = 100.0 + _random.nextDouble() * 100.0;
    final cloudHeight = 50.0 + _random.nextDouble() * 50.0;
    final cloudSize = Vector2(cloudWidth, cloudHeight);

    final speed = 15.0 + _random.nextDouble() * 30.0;

    final startX = -cloudWidth;
    final startY = _random.nextDouble() * (size.y * 0.4);

    final cloud = CloudComponent(position: Vector2(startX, startY), size: cloudSize, driftSpeed: speed);

    add(cloud);
    _clouds.add(cloud);
  }

  void _setupPlayerInitialPosition() {
    _rhenne.position.x = _pads[1].position.x;
    _rhenne.position.y = _pads[1].position.y - _rhenne.height + 25;
  }

  void _showWaveAnnouncement() {
    final wave = WaveIndicatorComponent(waveNumber: currentWave, position: size / 2);
    wave.anchor = Anchor.center;
    add(wave);
  }

  void resetGame() {
    resumeEngine();
    LaraAudio.startBgm(LaraBgm.rhenne);

    // Dynamic type matching lookup to clear items from the tree safely
    final activeItems = children.where(
      (c) =>
          c is CoinComponent ||
          c is AcornComponent ||
          c is BranchComponent ||
          c is HoneycombComponent ||
          c is PineconeComponent ||
          c is RedHeartComponent,
    );

    for (var item in activeItems) {
      item.removeFromParent();
    }

    currentWave = 1;
    _generateWaveItems();

    elapsedTime = 0.0;

    _currentLaneIndex = 1;
    _lastLandedPad = null;
    isGameOver = false;

    _setupPlayerInitialPosition();
    _rhenne.setAnimation(RhennePlayerCharacterState.idle);
    _showWaveAnnouncement();
  }

  void _triggerJump() {
    final targetPad = _pads[_currentLaneIndex];
    final targetPosition = Vector2(targetPad.position.x, targetPad.position.y - _rhenne.height + 25);
    _rhenne.jumpTo(targetPosition);
  }
}
