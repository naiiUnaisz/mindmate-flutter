import 'package:equatable/equatable.dart';
import 'package:application_belajar/models/user_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateUser extends ProfileEvent {
  final User user;

  const UpdateUser({required this.user});

  @override
  List<Object?> get props => [user];
}

class EarnCoins extends ProfileEvent {
  final int amount;
  final String reason;

  const EarnCoins({required this.amount, this.reason = 'task'});

  @override
  List<Object?> get props => [amount, reason];
}

class SpendCoins extends ProfileEvent {
  final int amount;
  final String reason;

  const SpendCoins({required this.amount, this.reason = 'exchange'});

  @override
  List<Object?> get props => [amount, reason];
}

class IncrementStreak extends ProfileEvent {}

class AddToWeeklyHistory extends ProfileEvent {
  final int tasks;
  final int coins;

  const AddToWeeklyHistory({required this.tasks, required this.coins});

  @override
  List<Object?> get props => [tasks, coins];
}

class UnlockPuzzle extends ProfileEvent {
  final String puzzleId;
  final int cost;

  const UnlockPuzzle({required this.puzzleId, required this.cost});

  @override
  List<Object?> get props => [puzzleId, cost];
}

class ActivateRestDay extends ProfileEvent {}

class DeactivateRestDay extends ProfileEvent {}

class ClearProfile extends ProfileEvent {}

class LogCoinTransaction extends ProfileEvent {
  final String type;
  final String title;
  final int amount;

  const LogCoinTransaction({
    required this.type,
    required this.title,
    required this.amount,
  });

  @override
  List<Object?> get props => [type, title, amount];
}

class CollectDailyPuzzle extends ProfileEvent {
  final String puzzleId;

  const CollectDailyPuzzle({required this.puzzleId});

  @override
  List<Object?> get props => [puzzleId];
}
