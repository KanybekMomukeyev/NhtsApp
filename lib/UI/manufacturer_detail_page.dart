import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhtsapp/Blocs/manufacturer_detail_bloc.dart';
import 'package:nhtsapp/Models/manufacturer_list_model.dart';
import 'package:nhtsapp/Models/manufacturer_make_model.dart';
import 'package:nhtsapp/UI/common_button.dart';

class ManufacturerDetailPage extends StatefulWidget {
  ManufacturerDetailPage({
    Key? key,
    required this.manufacturer,
  }) : super(key: key);
  final ManufacturerListModel manufacturer;
  @override
  _ManufacturerDetailPageState createState() => _ManufacturerDetailPageState();
}

class _ManufacturerDetailPageState extends State<ManufacturerDetailPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('initState _ManufacturerDetailPageState');
  }

  @override
  void deactivate() {
    debugPrint('deactivate _ManufacturerDetailPageState');
    BlocProvider.of<ManufacturerDetailBloc>(context).add(
      ManufacturerDetailInitialStarted(),
    );
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('dispose _ManufacturerDetailPageState');
    super.dispose();
  }

  Widget _buildDetailScreen(
    BuildContext context,
    List<ModelForMake> allModels,
  ) {
    return CustomScrollView(
      controller: ScrollController(keepScrollOffset: true),
      // physics: BouncingScrollPhysics(),
      // shrinkWrap: true,
      slivers: <Widget>[
        SliverAppBar(
            toolbarHeight: 0,
            expandedHeight: 100,
            backgroundColor: Colors.white,
            floating: false,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              centerTitle: true,
              background: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  widget.manufacturer.mfrName.toUpperCase(),
                  style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
        if (allModels.isEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    'Empty'.toUpperCase(),
                    style: TextStyle(fontSize: 20.0, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        SliverPadding(
            padding: const EdgeInsets.all(5.0),
            sliver: SliverList(
              // itemExtent: 150.0,
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final ModelForMake model = allModels[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.all(5),
                    elevation: 1.0,
                    child: InkWell(
                      splashColor: Colors.orange[300],
                      onTap: () async {},
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                model.modelName,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: allModels.length,
              ),
            ))
      ],
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
                'ERROR HAPPENED WHILE FETCHING',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 35.0),
              ErrorButton("ReTry", () {
                BlocProvider.of<ManufacturerDetailBloc>(context).add(
                  FetchManufacturerDetailPressed(
                      manufacturerId: widget.manufacturer.mfrId),
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
        title: const Text("Manufacturer detail screen"),
      ),
      body: BlocListener<ManufacturerDetailBloc, ManufacturerDetailState>(
        listener: (context, state) {},
        child: BlocBuilder<ManufacturerDetailBloc, ManufacturerDetailState>(
          builder: (context, state) {
            if (state is ManufacturerDetailFailure) {
              return buildErrorScreen(context);
            }
            if (state is ManufacturerDetailInProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ManufacturerDetailInitial) {
              BlocProvider.of<ManufacturerDetailBloc>(context).add(
                FetchManufacturerDetailPressed(
                    manufacturerId: widget.manufacturer.mfrId),
              );
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ManufacturerDetailSuccess) {
              return _buildDetailScreen(
                context,
                state.responseList,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
