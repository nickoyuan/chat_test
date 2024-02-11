import 'package:flutter/material.dart';
import 'package:flutter_app/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_event.dart';
import '../../../bloc/profile/profile_state.dart';
import '../../../utils/header.dart';

class ProfileSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfileSettings();
}

class _ProfileSettings extends State<ProfileSettings> {

  String genderPreference = 'Female';
  final List<bool> _selectedGender = <bool>[false, false, false, true];
  List<String> heightPreference = ["10 <", "10 - 20", "> 20", "Any"];

  double distanceRange = 20;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ProfileBloc>(context).add(ProfileFetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        bool value = await exitConfirmSave(context, ()=> {});
        if (value) {
          navigator.pop();
        }
      },
      child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: header("Preferences", context),
          body: BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
            if (state is ProfileSuccessState) {
              return userPreferences();
            } else if (state is Loading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is Error) {
              return errorWidget(
                  title: "Something went wrong", message: "please try again later");
            } else {
              return Center(child: Text("hello"));
            }
          })),
    );
  }

  Widget userPreferences() {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('Discovery Settings', style: const TextStyle(fontWeight: FontWeight.bold),),
        ),
        ListTile(
          title: Text('Distance'),
          trailing: getDistanceTitle(distanceRange),
          subtitle: Slider(
            divisions: 10,
            min: 0.0,
            max: 100.0,
            value: distanceRange,
            onChanged: (value) {
              setState(() {
                distanceRange = value;
              });
            },
          ),
        ),
        ListTile(
          title: Text('Height'),
          subtitle: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
            child: ToggleButtons(
                direction: Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedGender.length; i++) {
                      _selectedGender[i] = i == index;
                    }
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.black,
                selectedColor: Colors.black,
                fillColor: Colors.grey,
                color: Colors.white,
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: _selectedGender,
                children: heightPreference.map((gender) => Text(gender)).toList()),
          ),
        ),
        ListTile(
          title: Text("Gender Preference"),
          subtitle: DropdownButtonFormField(
            value: genderPreference,
            items: ["Male", "Female", "Both", "Non-binary"].map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                genderPreference = value as String;
              });
            },
          ),
        ),
        ListTile(
          title: Text("Ethnicity Preference"),
          subtitle: DropdownButtonFormField(
            value: genderPreference,
            items: ["Male", "Female", "Both", "Non-binary"].map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                genderPreference = value as String;
              });
            },
          ),
        ),
        ListTile(
          title: Text("Religion"),
          subtitle: DropdownButtonFormField(
            value: genderPreference,
            items: ["Male", "Female", "Both", "Non-binary"].map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                genderPreference = value as String;
              });
            },
          ),
        ),
        SizedBox(height: 20,),
        ListTile(
          title: Text('Notification Settings', style: const TextStyle(fontWeight: FontWeight.bold),),
        ),
        ListTile(
          title: Text('Messages'),
          trailing: Switch(
            value: true,
            onChanged: (bool value) {
              // Handle switch
            },
          ),
        ),
        ListTile(
          title: Text('Matches'),
          trailing: Switch(
            value: true,
            onChanged: (bool value) {
              // Handle switch
            },
          ),
        ),
        ListTile(
          title: Text('Likes'),
          trailing: Switch(
            value: true,
            onChanged: (bool value) {
              // Handle switch
            },
          ),
        ),
        SizedBox(
          height: 100,
        ),
      ],
    );
  }

  Widget getDistanceTitle(double distanceRange) {
    if(distanceRange >= 100) {
      return Text("Any distnace");
    } else {
      return Text("$distanceRange km");
    }
  }

  Padding listOfOptions(String title, Widget preferenceWidget) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          preferenceWidget
        ],
      ),
    );
  }
}