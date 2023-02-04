import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toearnfun_flutter_app/pages/vfe/vfe_detail.dart';
import 'package:toearnfun_flutter_app/types/vfe_detail.dart';

class VFEGridItemView extends StatelessWidget {
  VFEGridItemView(this.vfe);

  VFEDetail vfe;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color.fromARGB(255, Random().nextInt(256), Random().nextInt(256),
            Random().nextInt(256)),
        child: GestureDetector(
            child: Stack(children: [
              Center(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset('assets/images/vfe-item-common.png'))),
              Column(children: [
                Text('# ${vfe.itemId}'),
                Text('Lv ${vfe.level}'),
              ]),
            ]),
            onTap: () {
              Navigator.of(context).pushNamed(VFEDetailView.route, arguments: {
                'vfeDetail': vfe,
              });
            }));
  }
}
