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
import 'package:lara_demo/shared/falling_item.dart';
import 'package:lara_demo/core/lara_audio.dart';
import 'package:lara_demo/core/lara_base_game.dart';
import 'package:lara_demo/core/lara_theme.dart';

class RhenneJumpsGame extends LaraBaseGame with TapCallbacks, HasCollisionDetection {
  RhenneJumpsGame() : super(gradient: LaraGradients.pond, bgm: LaraBgm.rhenne);

  double elapsedTime = 0.0;
  late final RhennePlayerCharacterComponent _rhenne;
  int pointsCounter = 0;
  final List<CloudComponent> _clouds = [];
  final List<LilypadComponent> _pads = [];
  int _currentLaneIndex = 1;
  LilypadComponent? _lastLandedPad;

  bool isGameOver = false;

  int currentWave = 1;
  double baseItemSpeed = 200.0;
  final double speedIncreasePerWave = 25.0;
  final Random _random = Random();

  final List<LaneFallingItem> spawnItems = [];

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
              super.showGameOver(message: 'Oopsi!', onRestart: () {}, onHome: () {});
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
          } else if (other is RedHeartComponent) {
            LaraAudio.playSfx(LaraSfx.hitGood);
            final pop = PopTextComponent(showCoin: false, label: "+3 puntos", startPosition: other.position);
            add(pop);
            pointsCounter = pointsCounter + 3;
            super.setScore(pointsCounter);
          }
        }
      },
      size: Vector2(50, 50),
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
        case LaneFallingItemTypes.coin:
          fallingObject = CoinComponent(size: Vector2(75, 75));
          break;
        case LaneFallingItemTypes.acorn:
          fallingObject = AcornComponent(size: Vector2(40, 40));
          break;
        case LaneFallingItemTypes.branch:
          fallingObject = BranchComponent(size: Vector2(40, 40));
          break;
        case LaneFallingItemTypes.honeycomb:
          fallingObject = HoneycombComponent(size: Vector2(40, 40));
          break;
        case LaneFallingItemTypes.pinecone:
          fallingObject = PineconeComponent(size: Vector2(40, 40));
          break;
        case LaneFallingItemTypes.redHeart:
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

    // --- 1.0 to 11.0 Seconds ---
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 1, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 1, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 1, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 3, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 3, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 3, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 7, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 7, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 7, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 9, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 9, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.pinecone, spawnTimeInSeconds: 9, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 11, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.coin, spawnTimeInSeconds: 11, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 11, lane: 3));

    // --- 12.0 to 20.0 Seconds ---
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 12, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 12, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 12, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 13.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 13.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 13.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.pinecone, spawnTimeInSeconds: 15.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 15.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 15.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 17, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 17, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 17, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 19, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 19, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 19, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 20, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 20, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.pinecone, spawnTimeInSeconds: 20, lane: 3));

    // --- 21.5 to 30.0 Seconds ---
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 21.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 21.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 21.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 23.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 23.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 23.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 25, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.coin, spawnTimeInSeconds: 25, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 25, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.pinecone, spawnTimeInSeconds: 26.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.pinecone, spawnTimeInSeconds: 26.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 26.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 28.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 28.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 28.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 30, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 30, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 30, lane: 3));

    // --- 31.5 to 40.5 Seconds ---
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 31.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 31.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 31.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.pinecone, spawnTimeInSeconds: 33, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.coin, spawnTimeInSeconds: 33, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 33, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 35, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 35, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 35, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 36.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 36.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 36.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 38.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.pinecone, spawnTimeInSeconds: 38.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 38.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 40.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 40.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 40.5, lane: 3));

    // --- 42.0 to 50.5 Seconds ---
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 42, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.coin, spawnTimeInSeconds: 42, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 42, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 43.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 43.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 43.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 45, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.pinecone, spawnTimeInSeconds: 45, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 45, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 47, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 47, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 47, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 48.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 48.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.pinecone, spawnTimeInSeconds: 48.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 50.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 50.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 50.5, lane: 3));

    // --- 51.5 to 60.0 Seconds ---
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 51.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 51.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.pinecone, spawnTimeInSeconds: 51.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 53, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 53, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 53, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.branch, spawnTimeInSeconds: 54.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 54.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 54.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 56.5, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.pinecone, spawnTimeInSeconds: 56.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 56.5, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.honeycomb, spawnTimeInSeconds: 58, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.acorn, spawnTimeInSeconds: 58, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 58, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.coin, spawnTimeInSeconds: 60, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 60, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.coin, spawnTimeInSeconds: 60, lane: 3));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 61.0, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 61.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 62.0, lane: 3));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 62.5, lane: 2));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 63.0, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 63.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 64.0, lane: 3));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 64.5, lane: 2));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 65.0, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 65.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 66.0, lane: 3));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 66.5, lane: 2));

    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 67.0, lane: 1));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 67.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 68.0, lane: 3));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 68.5, lane: 2));
    spawnItems.add(LaneFallingItem(type: LaneFallingItemTypes.redHeart, spawnTimeInSeconds: 69.0, lane: 1));
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
    _rhenne.position.y = _pads[1].position.y - _rhenne.height;
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
    pointsCounter = 0;

    _currentLaneIndex = 1;
    _lastLandedPad = null;
    isGameOver = false;

    _setupPlayerInitialPosition();
    _rhenne.setAnimation(RhennePlayerCharacterState.idle);
    _showWaveAnnouncement();
  }

  void _triggerJump() {
    final targetPad = _pads[_currentLaneIndex];
    final targetPosition = Vector2(targetPad.position.x, targetPad.position.y - _rhenne.height);
    _rhenne.jumpTo(targetPosition);
  }
}
