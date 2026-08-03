part of 'home_cubit.dart';

class HomeState extends Equatable {
  final int selectedIndex;
  const HomeState({required this.selectedIndex});

  HomeState.init() : selectedIndex = 0;

  HomeState copyWith({int? selectedIndex}) {
    return HomeState(selectedIndex: selectedIndex ?? this.selectedIndex);
  }

  @override
  List<Object> get props => [selectedIndex];
}
