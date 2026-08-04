part of 'home_cubit.dart';

class HomeState extends Equatable {
  final int selectedIndex;
  final int itemsRefreshed;
  const HomeState({required this.selectedIndex, required this.itemsRefreshed});

  HomeState.init() : selectedIndex = 0, itemsRefreshed = 0;

  HomeState copyWith({int? selectedIndex, int? itemsRefreshed}) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      itemsRefreshed: itemsRefreshed ?? this.itemsRefreshed,
    );
  }

  @override
  List<Object> get props => [selectedIndex, itemsRefreshed];
}
