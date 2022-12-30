// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:games_services/games_services.dart' as gs;
import 'package:logging/logging.dart';

import 'score.dart';
//import 'package:game1/src/games_services/score.dart' as internal;
import 'package:game1/src/style/error_snackbar.dart';
import 'package:flutter/material.dart';

/// Allows awarding achievements and leaderboard scores,
/// and also showing the platforms' UI overlays for achievements
/// and leaderboards.
///
/// A facade of `package:games_services`.
class GamesServicesController {
  static final Logger _log = Logger('GamesServicesController');

  final Completer<bool> _signedInCompleter = Completer();

  Future<bool> get signedIn => _signedInCompleter.future;

  /// Signs into the underlying games service.
  Future<void> initialize() async {
    try {
      await gs.GamesServices.signIn();
      // The API is unclear so we're checking to be sure. The above call
      // returns a String, not a boolean, and there's no documentation
      // as to whether every non-error result means we're safely signed in.
      final signedIn = await gs.GamesServices.isSignedIn;
      _signedInCompleter.complete(signedIn);
    } catch (e) {
      _log.severe('Cannot log into GamesServices: $e');
      _signedInCompleter.complete(false);
    }
  }

  /// Launches the platform's UI overlay with achievements.
  Future<void> showAchievements() async {
    if (!await signedIn) {
      showErrorSnackbar(
        'sign in to view achivements',
        action: SnackBarAction(
          label: 'Sign in',
          onPressed: initialize,
        ),
      );
      _log.severe('Trying to show achievements when not logged in.');
      return;
    }

    try {
      await gs.GamesServices.showAchievements();
    } catch (e) {
      _log.severe('Cannot show achievements: $e');
    }
  }

  /// Launches the platform's UI overlay with leaderboard(s).
  Future<void> showLeaderboard() async {
    if (!await signedIn) {
      showErrorSnackbar(
        'sign in to view leaderboard',
        action: SnackBarAction(
          label: 'Sign in',
          onPressed: initialize,
        ),
      );
      _log.severe('Trying to show leaderboard when not logged in.');
      return;
    }

    try {
      await gs.GamesServices.showLeaderboards(
        iOSLeaderboardID: "game1.highest_score",
        androidLeaderboardID: "CgkIgZ29mawJEAIQAQ",
      );
    } catch (e) {
      _log.severe('Cannot show leaderboard: $e');
    }
  }

  void awardAchievement({required String iOS, required String android}) async {
    if (!await signedIn) {
      _log.warning('Trying to award achievement when not logged in.');
      return;
    }

    try {
      await gs.GamesServices.unlock(
        achievement: gs.Achievement(
          androidID: android,
          iOSID: iOS,
        ),
      );
    } catch (e) {
      _log.severe('Cannot award achievement: $e');
    }
  }

  /// Submits [score] to the leaderboard.
  Future<void> submitLeaderboardScore(Score score) async {
    if (!await signedIn) {
      _log.warning('Trying to submit leaderboard when not logged in.');
      return;
    }

    _log.info('Submitting $score to leaderboard.');

    try {
      await gs.GamesServices.submitScore(
        score: gs.Score(
          iOSLeaderboardID: 'game1.highest_score',
          androidLeaderboardID: 'CgkIgZ29mawJEAIQAQ',
          value: score.score,
        ),
      );
    } catch (e) {
      _log.severe('Cannot submit leaderboard score: $e');
    }
  }
}
