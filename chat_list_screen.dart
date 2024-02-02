import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/chatListBloc/chat_list_bloc.dart';
import 'package:flutter_app/bloc/chatListBloc/chat_list_event.dart';
import 'package:flutter_app/bloc/chatListBloc/chat_list_state.dart';
import 'package:flutter_app/model/conversation_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/header.dart';
import '../../utils/utility.dart';
import 'message.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatListBloc>(context)
        .add(FetchListEvent(isPullToRefresh: false));
  }

  Future<void> _onRefresh() async {
    return BlocProvider.of<ChatListBloc>(context)
        .add(FetchListEvent(isPullToRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header("Matches", context),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(),
        child: BlocBuilder<ChatListBloc, ChatListState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            switch (state.runtimeType) {
              case Loading:
                // Handle the initial state
                return loadingSpinner("Loading chat list");
              case Empty:
                // Handle the loading state
                return CircularProgressIndicator();
              case Success:
                if ((state as Success).conversationList.length > 0) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                          child: _buildChatList((state as Success).conversationList))
                    ],
                  );
                } else {
                  return Center(
                    child: ListView(children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          emptyWidget(
                              title: 'No matches so far',
                              message: "start swiping to get paired")
                        ],
                      )
                    ]),
                  );
                }
              case Error:
                return emptyWidget(
                    title: 'No matches so far',
                    message: "start swiping to get paired");
              default:
                return errorWidget(
                    title: "Something went wrong",
                    message: "please try again later");
            }
          },
        ),
      ),
    );
  }

  Widget _buildChatList(List<ConversationModel> profile) {
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) => SizedBox(
        height: 10,
      ),
      itemCount: profile.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: checkUnreadConversation(profile, index),
          onTap: () {
            if (profile[index].lastMessage?.sender ==
                    profile[index].swiped_user_id &&
                profile[index].lastMessage?.messageOpened == false) {
              BlocProvider.of<ChatListBloc>(context).add(
                  UpdateLastSeenMessageEvent(conversationModel: profile[index]));
              setState(() {
                profile[index].lastMessage?.messageOpened = true;
              });
            }
            // updateState and update the unseen message
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Message(profile[index])));
          },
        );
      },
    );
  }

  Widget checkUnreadConversation(List<ConversationModel> profile, int index) {
    if (profile[index].lastMessage?.sender == profile[index].swiped_user_id &&
        profile[index].lastMessage?.messageOpened == false) {
      return Container(
          color: Colors.grey[200], child: conversationTile(profile, index));
    } else {
      return conversationTile(profile, index);
    }
  }

  ListTile conversationTile(List<ConversationModel> profile, int index) {
    return ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/images/woman2.jpg'),
          // TODO - Change to Network Image
          backgroundColor: Colors.transparent,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(profile[index].swiped_user_profile_name),
            Text('11:30 AM', style: TextStyle(fontSize: 12)),
          ],
        ),
        subtitle: Text("hello"));
  }
}
