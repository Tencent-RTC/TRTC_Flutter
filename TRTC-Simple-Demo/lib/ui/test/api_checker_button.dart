
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trtc_demo/ui/test/callback_checker.dart';
import 'package:trtc_demo/ui/test/parameter_type.dart';
import 'package:trtc_demo/utils/tool.dart';

enum ButtonStatus {
  notChecked,
  checking,
  failed,
  success,
}

class ApiCheckerButton extends StatefulWidget {
  final String methodName;
  final String token;
  final List<Parameter> parameters;
  final String? extString;
  final void Function(Map<String, dynamic> params) callApi;

  ApiCheckerButton({
    required this.methodName,
    required this.parameters,
    this.extString,
    required this.callApi,
    String? token,
  }) : token = token ?? methodName;

  @override
  _ApiCheckerButtonState createState() => _ApiCheckerButtonState();
}

class _ApiCheckerButtonState extends State<ApiCheckerButton> {
  ButtonStatus _status = ButtonStatus.notChecked;
  String _log = '';

  void _showParameterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Current Parameters'),
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.parameters.map((param) {
                // 处理 value 的显示
                String valueDisplay;
                valueDisplay = param.value.toString();
                return Text('${param.name} (${param.type}): $valueDisplay');
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case ButtonStatus.notChecked:
        return Colors.grey;
      case ButtonStatus.checking:
        return Colors.yellow;
      case ButtonStatus.failed:
        return Colors.red;
      case ButtonStatus.success:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  _onClickMethod() {
    setState(() {
      _status = ButtonStatus.checking;
    });
    Map<String, dynamic> params = {};
    for (Parameter parameter in widget.parameters) {
      params[parameter.name] = parameter.value;
    }
    widget.callApi(params);
    CallbackChecker.setValidationToken(
      widget.token,
      CheckerCallback(
              (bool checkerResult, String errMsg) {
            if (checkerResult) {
              setState(() {
                _status = ButtonStatus.success;
                _log = errMsg;
              });
            } else {
              setState(() {
                _status = ButtonStatus.failed;
                MeetingTool.toast(errMsg, context);
              });
            }
          }
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text("token: ${widget.token}"),
                              Text("log: $_log"),
                            ],
                          ),
                        ),
                      );
                    }
                );
              },
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                ),
              ),
          ),
          SizedBox(height: 8.0),
          TextButton(
              onPressed: _onClickMethod,
              child: Text(widget.methodName),
          ),
          SizedBox(height: 8.0),
          TextButton(
              onPressed: _showParameterDialog,
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(8.0),
                side: BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text(widget.extString ?? 'params'),
          ),
        ],
      ),
    );
  }

}