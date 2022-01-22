package com.julyseven.wonbridge.model;


import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Commons;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;

/**
 * Created by JIS on 12/21/2015.
 */
public class RoomEntity implements Serializable {

    String _name = "";
    String _participants = "";          // contains my id
    ArrayList<FriendEntity> _participantList = new ArrayList<>();       // not contains me
    ArrayList<FriendEntity> _leaveMemberList = new ArrayList<>();       // not contains me

    String _recentContent = "";
    String _recentTime = "";
    int _recentCounter = 0;
    String _leaveMembers = "";

    String _nickName = "Group";
     String _profileUrl = "";

    private boolean _isSelected = false;


    public RoomEntity(ArrayList<FriendEntity> participants) {

        _participantList = participants;

        if (_participantList.size() == 1)   // 1:1
            _name = makeParticipants();
        else    // group chatting each name is different
            _name = makeParticipants() + "_" + System.currentTimeMillis();

        _participants = makeParticipants();
    }

    public RoomEntity(String roomname) {

        _name = roomname;
    }

    public RoomEntity(String name, String participants, String recentContent, String recentTime, int recentCounter, String leaveMembers) {

        _name = name;
        _recentContent = recentContent;
        _recentTime = recentTime;
        _recentCounter = recentCounter;
        _participants = participants;
        _leaveMembers = leaveMembers;

    }


    public String get_name() {
        return _name;
    }

    public void set_name(String _name) {
        this._name = _name;
    }

    public String get_participants() {
        return _participants;
    }

    public void set_participants(String _participants) {
        this._participants = _participants;
    }

    public ArrayList<FriendEntity> get_participantList() {
        return _participantList;
    }

    public void set_participantList(ArrayList<FriendEntity> _participantList) {
        this._participantList = _participantList;
    }

    public String get_recentContent() {
        return _recentContent;
    }

    public void set_recentContent(String _recentContent) {
        this._recentContent = _recentContent;
    }

    public String get_recentTime() {
        return _recentTime;
    }

    public void set_recentTime(String _recentTime) {
        this._recentTime = _recentTime;
    }

    public int get_recentCounter() {
        return _recentCounter;
    }

    public void set_recentCounter(int _recentCounter) {
        this._recentCounter = _recentCounter;
    }

    public void add_rcentCounter() {
        set_recentCounter(_recentCounter + 1);
    }

    public void init_recentCounter() {
        set_recentCounter(0);
    }

    public boolean is_isSelected() {
        return _isSelected;
    }

    public void set_isSelected(boolean _isSelected) {
        this._isSelected = _isSelected;
    }


     public String get_leaveMembers() {
         return _leaveMembers;
     }

     public void set_leaveMembers(String _leaveMembers) {
         this._leaveMembers = _leaveMembers;
     }

     public String get_nickName() {
         return _nickName;
     }

     public void set_nickName(String _nickName) {
         this._nickName = _nickName;
     }

     public String get_profileUrl() {
         return _profileUrl;
     }

     public void set_profileUrl(String _profileUrl) {
         this._profileUrl = _profileUrl;
     }

     public String makeParticipants() {

        String roomName = "";

        ArrayList<Integer> ids = new ArrayList<Integer>();

        for (FriendEntity entity : _participantList) {
            ids.add(Integer.valueOf(entity.get_idx()));
        }
        ids.add(Integer.valueOf(Commons.g_user.get_idx()));

        Collections.sort(ids);

        for (Integer id : ids) {
            roomName += id + "_";
        }

        roomName = roomName.substring(0, roomName.length() - 1);

        return roomName;

    }


     public String makeParticipantsWithoutLeaveMemeber(boolean involveme) {

         String roomName = "";

         String[] leaveMemberIds = get_leaveMembers().split("_");
         ArrayList<String> leaveIdList = new ArrayList<>(Arrays.asList(leaveMemberIds));

         ArrayList<Integer> ids = new ArrayList<Integer>();

         for (FriendEntity entity : _participantList) {

             if (leaveIdList.contains(String.valueOf(entity.get_idx())))
                 continue;

             ids.add(Integer.valueOf(entity.get_idx()));
         }
         if (involveme)
            ids.add(Integer.valueOf(Commons.g_user.get_idx()));

         Collections.sort(ids);

         for (Integer id : ids) {
             roomName += id + "_";
         }

         roomName = roomName.substring(0, roomName.length() - 1);

         return roomName;

     }

    public String makeParticipantsWithLeaveMemeber() {

        String roomName = "";

        ArrayList<Integer> ids = new ArrayList<Integer>();

        if (get_participants().length() > 0) {
            String[] participantIds = get_participants().split("_");
            ArrayList<String> partList = new ArrayList<>(Arrays.asList(participantIds));

            for (String partId : partList) {
                Integer intId = Integer.parseInt(partId);

                if (!ids.contains(intId))
                    ids.add(intId);
            }
        }

        if (get_leaveMembers().length() > 0) {

            String[] leaveMemberIds = get_leaveMembers().split("_");
            ArrayList<String> leaveIdList = new ArrayList<>(Arrays.asList(leaveMemberIds));

            for (String leaveId : leaveIdList) {
                Integer intId = Integer.parseInt(leaveId);

                if (!ids.contains(intId))
                    ids.add(intId);
            }
        }

        Collections.sort(ids);

        for (Integer id : ids) {
            roomName += id + "_";
        }

        roomName = roomName.substring(0, roomName.length() - 1);

        return roomName;

    }


    public String get_displayName() {

        String displayName = "";

        // 1:1 chatting
        if (_participantList.size() == 1) {
            return _participantList.get(0).get_name();
        }

        // group chatting
        String[] leaveMemberIds = get_leaveMembers().split("_");
        ArrayList<String> leaveIdList = new ArrayList<>(Arrays.asList(leaveMemberIds));

        ArrayList<Integer> ids = new ArrayList<Integer>();

        for (FriendEntity entity : _participantList) {
            ids.add(Integer.valueOf(entity.get_idx()));
        }
        Collections.sort(ids);

        for (Integer id : ids) {

            // if leave member
            if (leaveIdList.contains(String.valueOf(id.intValue())))
                continue;

            for (FriendEntity entity : _participantList) {

                if (id == entity.get_idx()) {
                    displayName += entity.get_name() + ", ";
                    break;
                }
            }

        }

        if (displayName.length() == 0) {
            displayName = Commons.g_currentActivity.getString(R.string.group);
        } else if (displayName.length() > 2)
            displayName = displayName.substring(0, displayName.length() - 2);


        return displayName;
    }

    public String get_displayCount() {

        String displayCount = "";

        if (_participantList.size() >= 2) {

            int leaveCount = 0;
            if (get_leaveMembers().length() > 0) {
                leaveCount = get_leaveMembers().split("_").length;
            }
            displayCount += " (" + String.valueOf(_participantList.size() - leaveCount + 1) + ")";
        }

        return displayCount;
    }

    public FriendEntity getParticipant(int idx) {

        for (FriendEntity friend : _participantList) {

            if (friend.get_idx() == idx)
                return friend;
        }

        return null;
    }

    public void removeParticipant(int idx) {

        String[] ids = _participants.split("_");
        ArrayList<String> idList = new ArrayList<>(Arrays.asList(ids));

        if (idList.contains(String.valueOf(idx))) {
            idList.remove(String.valueOf(idx));
        }

        Collections.sort(idList, new Comparator<String>() {
            @Override
            public int compare(String lhs, String rhs) {
                return new Integer(lhs).compareTo(new Integer(rhs));
            }
        });

        String participant = "";
        for (String id : idList) {
            participant += id + "_";
        }

        if (participant.length() > 0)
            participant = participant.substring(0, participant.length() - 1);

        _participants = participant;

    }


    @Override
    public boolean equals(Object o) {

        RoomEntity other = (RoomEntity) o;
        return (get_name().equalsIgnoreCase(other.get_name()));
    }


    public boolean isGroup() {

        if (get_name().split("_").length > 2)
            return true;

        return false;
    }
}
