import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:lara_demo/components/bird_component.dart';
import 'package:lara_demo/components/bone_component.dart';
import 'package:lara_demo/components/cloud2_component.dart';
import 'package:lara_demo/components/coin_component.dart';
import 'package:lara_demo/components/galleta_player_character_component.dart';
import 'package:lara_demo/components/ground_component.dart';
import 'package:lara_demo/components/hearts/red_heart_component.dart';
import 'package:lara_demo/components/pop_text_component.dart';
import 'package:lara_demo/components/rock_component.dart';
import 'package:lara_demo/components/wave_indicator_component.dart';
import 'package:lara_demo/core/lara_audio.dart';
import 'package:lara_demo/core/lara_base_game.dart';
import 'package:lara_demo/core/lara_theme.dart';
import 'package:lara_demo/components/hill_component.dart';
import 'package:lara_demo/games/galleta_run/components/sky_layer.dart';
import 'package:lara_demo/widgets/falling_lane_item.dart';

class GalletaRunsGame extends LaraBaseGame with TapCallbacks, HasCollisionDetection {
  GalletaRunsGame() : super(gradient: LaraGradients.sunny, bgm: LaraBgm.galleta);

  late final GalletaPlayerCharacterComponent _galleta;
  final _random = Random();

  double _elapsedTime = 0.0;
  int _currentWave = 1;
  double baseItemSpeed = 400.0;
  final double speedIncreasePerWave = 25.0;
  double get groundSpeed => 100.0;
  double get groundY => size.y * 0.82;

  final List<FallingLaneItem> spawnItems = [];

  @override
  Future onLoad() async {
    super.onLoad();
    _addBackground();

    _galleta = GalletaPlayerCharacterComponent(
      size: Vector2(50, 50),

      position: Vector2(50, groundY),
      onCollisionStarted: (player, other) {
        if (other is BirdComponent || other is RockComponent) {
          LaraAudio.stopBgm();
          LaraAudio.playSfx(LaraSfx.miss);
          _galleta.die(
            onAnimationComplete: () {
              super.showGameOver(message: '¡Muy bien!', onRestart: () {}, onHome: () {});
              pauseEngine();
            },
          );
        }

        if (other is BoneComponent || other is CoinComponent || other is RedHeartComponent) {
          other.removeFromParent();

          if (other is BoneComponent) {
            LaraAudio.playSfx(LaraSfx.hitGood);
            final pop = PopTextComponent(showCoin: false, label: "+5 puntos", startPosition: Vector2(other.position.x + 25, other.position.y));
            add(pop);
            super.addPoints(5);
          } else if (other is CoinComponent) {
            LaraAudio.playSfx(LaraSfx.coin);
            final pop = PopTextComponent(showCoin: true, label: "+1 moneda", startPosition: Vector2(other.position.x + 25, other.position.y));
            add(pop);
            super.addCoins(1);
          } else if (other is RedHeartComponent) {
            LaraAudio.playSfx(LaraSfx.hitGood);
            final pop = PopTextComponent(showCoin: false, label: "+3 puntos", startPosition: Vector2(other.position.x + 25, other.position.y));
            add(pop);
            super.addPoints(3);
          }
        }
      },
    );

    await add(_galleta);

    _currentWave = 1;
    _showWaveAnnouncement();
    _generateWaveItems();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsedTime += dt;

    _spawnItems();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_galleta.isDead) return;
    if (_galleta.isJumping) return;

    _galleta.jump();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Update points
  }

  void _addBackground() {
    add(SkyLayer(screenWidth: size.x, screenHeight: size.y, rng: _random));

    final hillDefs = [
      (x: 0.0, w: 290.0, h: 180.0, color: LaraColors.mint.withValues(alpha: 0.42), spd: 18.0),
      (x: 230.0, w: 230.0, h: 145.0, color: LaraColors.rhenneGreen.withValues(alpha: 0.32), spd: 25.0),
      (x: 460.0, w: 270.0, h: 165.0, color: LaraColors.mint.withValues(alpha: 0.38), spd: 21.0),
    ];
    for (final d in hillDefs) {
      add(
        HillComponent(
          startPosition: Vector2(d.x, groundY - d.h + 14),
          hillWidth: d.w,
          hillHeight: d.h,
          scrollSpeed: d.spd,
          color: d.color,
          rng: _random,
        ),
      );
    }

    final cloudDefs = [
      (x: 55.0, y: 48.0, w: 115.0, spd: 30.0),
      (x: 285.0, y: 82.0, w: 92.0, spd: 22.0),
      (x: 490.0, y: 38.0, w: 132.0, spd: 27.0),
    ];
    for (final d in cloudDefs) {
      add(Cloud2Component(startPosition: Vector2(d.x, d.y), cloudWidth: d.w, scrollSpeed: d.spd, rng: _random));
    }

    final farCloudDefs = [
      (x: 30.0, y: 130.0, w: 68.0, spd: 10.0),
      (x: 240.0, y: 110.0, w: 54.0, spd: 12.0),
      (x: 430.0, y: 145.0, w: 74.0, spd: 9.0),
      (x: 610.0, y: 118.0, w: 60.0, spd: 11.0),
    ];
    for (final d in farCloudDefs) {
      add(
        Cloud2Component(
          startPosition: Vector2(d.x, d.y),
          cloudWidth: d.w,
          scrollSpeed: d.spd,
          rng: _random,
          renderPriority: -45,
        ),
      );
    }

    add(GroundComponent(groundY: groundY, screenWidth: size.x, screenHeight: size.y));
  }

  void _showWaveAnnouncement() {
    final wave = WaveIndicatorComponent(waveNumber: _currentWave, position: size / 2);
    wave.anchor = Anchor.center;
    add(wave);
  }

  void _generateWaveItems() {
    spawnItems.clear();

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 3, type: FallingLaneItemTypes.coin));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 3, type: FallingLaneItemTypes.bone));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 5, type: FallingLaneItemTypes.redHeart));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 5, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 7, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 7, type: FallingLaneItemTypes.redHeart));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 9, type: FallingLaneItemTypes.coin));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 9, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 9, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 11, type: FallingLaneItemTypes.redHeart));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 11, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 13, type: FallingLaneItemTypes.coin));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 13, type: FallingLaneItemTypes.coin));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 13, type: FallingLaneItemTypes.redHeart));

    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 15, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 17, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 17, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 19, type: FallingLaneItemTypes.rock));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 19, type: FallingLaneItemTypes.bird));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 21, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 21, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 23, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 23, type: FallingLaneItemTypes.redHeart));

    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 25, type: FallingLaneItemTypes.rock));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 25, type: FallingLaneItemTypes.bone));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 27, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 27, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 29, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 29, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 31, type: FallingLaneItemTypes.coin));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 31, type: FallingLaneItemTypes.redHeart));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 31, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 33, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 33, type: FallingLaneItemTypes.redHeart));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 33, type: FallingLaneItemTypes.redHeart));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 35, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 35, type: FallingLaneItemTypes.bird));

    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 37, type: FallingLaneItemTypes.rock));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 37, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 39, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 39, type: FallingLaneItemTypes.bone));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 41, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 41, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 43, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 43, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 45, type: FallingLaneItemTypes.redHeart));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 45, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 47, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 47, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 49, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 49, type: FallingLaneItemTypes.bone));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 51, type: FallingLaneItemTypes.redHeart));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 51, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 53, type: FallingLaneItemTypes.rock));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 53, type: FallingLaneItemTypes.bird));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 55, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 55, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 57, type: FallingLaneItemTypes.redHeart));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 57, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 59, type: FallingLaneItemTypes.coin));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 59, type: FallingLaneItemTypes.coin));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 59, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 61, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 61, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 63, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 63, type: FallingLaneItemTypes.redHeart));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 65, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 65, type: FallingLaneItemTypes.bird));

    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 67, type: FallingLaneItemTypes.rock));
    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 67, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 69, type: FallingLaneItemTypes.redHeart));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 69, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 71, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 71, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 73, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 73, type: FallingLaneItemTypes.bone));

    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 75, type: FallingLaneItemTypes.rock));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 75, type: FallingLaneItemTypes.redHeart));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 77, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 77, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 79, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 79, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 81, type: FallingLaneItemTypes.redHeart));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 81, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 83, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 83, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 85, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 85, type: FallingLaneItemTypes.bone));

    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 87, type: FallingLaneItemTypes.rock));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 87, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 89, type: FallingLaneItemTypes.coin));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 89, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 89, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 91, type: FallingLaneItemTypes.coin));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 91, type: FallingLaneItemTypes.redHeart));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 91, type: FallingLaneItemTypes.coin));

    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 93, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 95, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 95, type: FallingLaneItemTypes.redHeart));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 97, type: FallingLaneItemTypes.redHeart));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 97, type: FallingLaneItemTypes.bird));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 97, type: FallingLaneItemTypes.rock));

    spawnItems.add(FallingLaneItem(lane: 1, spawnTimeInSeconds: 99, type: FallingLaneItemTypes.coin));
    spawnItems.add(FallingLaneItem(lane: 2, spawnTimeInSeconds: 99, type: FallingLaneItemTypes.bone));
    spawnItems.add(FallingLaneItem(lane: 3, spawnTimeInSeconds: 99, type: FallingLaneItemTypes.rock));
  }

  void _spawnItems() {
    final itemsToSpawn = spawnItems.where((i) => !i.isProcessed && i.spawnTimeInSeconds <= _elapsedTime);
    final yValues = [groundY, groundY - 100, groundY - 50, groundY];
    final double currentSpeed = baseItemSpeed + ((_currentWave - 1) * speedIncreasePerWave);
    final double totalDistance = (size.x * 2) + 300;
    final double moveDuration = totalDistance / currentSpeed;

    for (var item in itemsToSpawn) {
      if (item.type == FallingLaneItemTypes.bird) {
        item.isProcessed = true;
        final bird = BirdComponent(size: Vector2(50, 50), position: Vector2(size.x + 100, yValues[item.lane]));

        final target = Vector2(-(size.x + 200), 0);
        bird.move(target, moveDuration);
        add(bird);
      }

      if (item.type == FallingLaneItemTypes.bone) {
        item.isProcessed = true;
        final bone = BoneComponent(size: Vector2(50, 50), position: Vector2(size.x + 100, yValues[item.lane]));

        final target = Vector2(-(size.x + 200), 0);
        bone.move(target, moveDuration);
        add(bone);
      }

      if (item.type == FallingLaneItemTypes.coin) {
        item.isProcessed = true;
        final coin = CoinComponent(size: Vector2(60, 60), position: Vector2(size.x + 100, yValues[item.lane]));

        final target = Vector2(-(size.x + 200), 0);
        coin.move(target, moveDuration);
        add(coin);
      }

      if (item.type == FallingLaneItemTypes.redHeart) {
        item.isProcessed = true;
        final heart = RedHeartComponent(size: Vector2(60, 60), position: Vector2(size.x + 100, yValues[item.lane]));

        final target = Vector2(-(size.x + 200), 0);
        heart.move(target, moveDuration);
        add(heart);
      }

      if (item.type == FallingLaneItemTypes.rock) {
        item.isProcessed = true;
        final rock = RockComponent(size: Vector2(50, 50), position: Vector2(size.x + 100, yValues[item.lane]));

        final target = Vector2(-(size.x + 200), 0);
        rock.move(target, moveDuration);
        add(rock);
      }
    }

    if (spawnItems.isEmpty) return;

    final activeItems = children.where(
      (c) =>
          c is BirdComponent ||
          c is BoneComponent ||
          c is RockComponent ||
          c is CoinComponent ||
          c is RedHeartComponent,
    );

    final allItemsSpawned = spawnItems.every((item) => item.isProcessed);
    if (allItemsSpawned && activeItems.isEmpty) {
      _currentWave++;
      _elapsedTime = 0.0;
      _showWaveAnnouncement();
      _generateWaveItems();
    }
  }
}
