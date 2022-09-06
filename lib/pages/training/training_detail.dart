
import 'package:flutter/cupertino.dart';
import 'package:toearnfun_flutter_app/common/types/training_report.dart';

class TrainingDetailView extends StatefulWidget {
  TrainingDetailView(this.data);

  JumpRopeTrainingData data;

  @override
  State<TrainingDetailView> createState() => _TrainingDetailViewState();
}

class _TrainingDetailViewState extends State<TrainingDetailView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        //[headview, detail, button]

      ],),
    );
  }

  Widget headView() {
    return Container();
  }

  Widget detailView() {
    return Container();
  }
}
