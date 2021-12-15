import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhtsapp/Blocs/manufacturers_list_bloc.dart';
import 'package:nhtsapp/Models/manufacturer_list_model.dart';
import 'package:nhtsapp/UI/common_button.dart';
import 'package:nhtsapp/UI/manufacturer_detail_page.dart';

int _nextPage = 1;

class ManufacturersListPage extends StatefulWidget {
  const ManufacturersListPage({
    Key? key,
  }) : super(key: key);

  @override
  _ManufacturersListPageState createState() => _ManufacturersListPageState();
}

class _ManufacturersListPageState extends State<ManufacturersListPage> {
  final _scrollController = ScrollController();
  final List<ManufacturerListModel> _responseList = [];

  @override
  void initState() {
    super.initState();
    debugPrint('initState _ManufacturersListPageState');
    _scrollController.addListener(_onScroll);
  }

  @override
  void deactivate() {
    debugPrint('deactivate _ManufacturersListPageState');
    BlocProvider.of<ManufacturersListBloc>(context).add(
      ManufacturersListInitialStarted(),
    );
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('dispose _ManufacturersListPageState');
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      debugPrint("_isBottom reached");
      debugPrint("Fetch manufacturers for page $_nextPage");
      BlocProvider.of<ManufacturersListBloc>(context).add(
        FetchManufacturersListPressed(page: _nextPage),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Widget _buildListResponse(
    BuildContext context,
    List<ManufacturerListModel> responseList,
  ) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return index >= responseList.length
            ? const _BottomLoader()
            : _ManufacturerListItem(manufacturer: responseList[index]);
      },
      itemCount: responseList.length + 1,
      controller: _scrollController,
    );
  }

  Widget buildErrorScreen(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 15.0),
              Text(
                'ERROR HAPPENED',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 35.0),
              ErrorButton("ReTry", () {
                BlocProvider.of<ManufacturersListBloc>(context).add(
                  FetchManufacturersListPressed(page: _nextPage),
                );
              }),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manufacturers list"),
      ),
      body: BlocListener<ManufacturersListBloc, ManufacturersListState>(
        listener: (context, state) {},
        child: BlocBuilder<ManufacturersListBloc, ManufacturersListState>(
          builder: (context, state) {
            if (state is ManufacturersListFailure) {
              return buildErrorScreen(context);
            }
            if (state is ManufacturersListInitial) {
              BlocProvider.of<ManufacturersListBloc>(context).add(
                FetchManufacturersListPressed(page: _nextPage),
              );
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ManufacturersListSuccess) {
              _nextPage = state.nextPage;
              _responseList.addAll(state.responseList);
              return _buildListResponse(
                context,
                _responseList,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _BottomLoader extends StatelessWidget {
  const _BottomLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }
}

class _ManufacturerListItem extends StatelessWidget {
  const _ManufacturerListItem({
    Key? key,
    required this.manufacturer,
  }) : super(key: key);

  final ManufacturerListModel manufacturer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      child: ListTile(
        leading: Text('${manufacturer.mfrId}', style: textTheme.caption),
        title: Text(manufacturer.country),
        isThreeLine: true,
        subtitle: Text(manufacturer.mfrName),
        dense: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManufacturerDetailPage(
                      manufacturer: manufacturer,
                    )),
          );
        },
      ),
    );
  }
}
