package com.julyseven.wonbridge.adapter;

import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.daimajia.swipe.SimpleSwipeListener;
import com.daimajia.swipe.SwipeLayout;
import com.daimajia.swipe.adapters.BaseSwipeAdapter;
import com.julyseven.wonbridge.Chatting.GroupChattingActivity;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.message.MsgActivity;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.GroupEntity;
import com.julyseven.wonbridge.model.RoomEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

/**
 * Created by sss on 8/24/2016.
 */
public class ChattingListAdapter extends BaseSwipeAdapter {

    private MsgActivity _context;

    private ArrayList<RoomEntity> _roomDatas = new ArrayList<>();

    public ChattingListAdapter(MsgActivity context){

        super();
        this._context = context;
    }


    public void setRoomData(ArrayList<RoomEntity> data) {

        _roomDatas = data;
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return _roomDatas.size();
    }

    @Override
    public Object getItem(int position) {
        return null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public int getSwipeLayoutResourceId(int position) {
        return R.id.swipe;
    }

    @Override
    public View generateView(final int position, ViewGroup parent) {

        View v = LayoutInflater.from(_context).inflate(R.layout.item_chatting_list, null);
        final SwipeLayout swipeLayout = (SwipeLayout)v.findViewById(getSwipeLayoutResourceId(position));

        swipeLayout.addSwipeListener(new SimpleSwipeListener() {
            @Override
            public void onOpen(SwipeLayout layout) {
            }
        });

        v.findViewById(R.id.txv_read).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                _context.onClickRead(position);
                swipeLayout.close();
            }
        });

        v.findViewById(R.id.txv_delete).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                _context.onClickDelete(position);
                swipeLayout.close();
            }
        });

        return v;
    }

    @Override
    public void fillValues(int position, View convertView) {

        ImageView imvUserPhoto = (ImageView) convertView.findViewById(R.id.imv_user_photo);
        FrameLayout fltGroupPhoto = (FrameLayout) convertView.findViewById(R.id.flt_group_photo);
        ImageView imvGroupPhoto = (ImageView) convertView.findViewById(R.id.imv_group_photo);
        LinearLayout lytGroupPhoto = (LinearLayout) convertView.findViewById(R.id.lyt_photo);
        ImageView imvGroupPhoto1 = (ImageView) convertView.findViewById(R.id.imv_photo1);
        ImageView imvGroupPhoto2 = (ImageView) convertView.findViewById(R.id.imv_photo2);
        ImageView imvGroupPhoto3 = (ImageView) convertView.findViewById(R.id.imv_photo3);
        ImageView imvGroupPhoto4 = (ImageView) convertView.findViewById(R.id.imv_photo4);

        TextView txvChattingUserName = (TextView) convertView.findViewById(R.id.txv_chatting_name);
        TextView txvChattingMessage = (TextView) convertView.findViewById(R.id.txv_chatting_message);
        TextView txvChattingTime = (TextView) convertView.findViewById(R.id.txv_chatting_time);
        TextView txvChattingStateNumber = (TextView) convertView.findViewById(R.id.txv_chatting_state_number);
        ImageView imvFlag = (ImageView) convertView.findViewById(R.id.imv_flag);
        ImageView imvFlag2 = (ImageView) convertView.findViewById(R.id.imv_flag2);

        final RoomEntity room = _roomDatas.get(position);

        if (!room.isGroup()) {  // 1:1

            imvUserPhoto.setVisibility(View.VISIBLE);
            fltGroupPhoto.setVisibility(View.GONE);

            txvChattingUserName.setText(room.get_displayName() + room.get_displayCount());
            txvChattingMessage.setText(room.get_recentContent());
            txvChattingTime.setText(Commons.getChattingDisplayTime(room.get_recentTime()));

            if (room.get_recentCounter() > 0) {
                txvChattingStateNumber.setText(String.valueOf(room.get_recentCounter()));
                txvChattingStateNumber.setVisibility(View.VISIBLE);
            } else {
                txvChattingStateNumber.setVisibility(View.INVISIBLE);
            }


            String[] parti = room.get_participants().split("_");

            int otherIdx = Integer.parseInt(parti[0]);
            if (otherIdx == Commons.g_user.get_idx())
                otherIdx = Integer.parseInt(parti[1]);

            FriendEntity friend = room.getParticipant(otherIdx);
            if (friend != null) {
                Glide.with(_context).load(friend.get_photoUrl()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(imvUserPhoto);

                String pngName = "ic_flag_flat_" + friend.get_country().trim().toLowerCase();
                imvFlag.setImageResource(_context.getResources().getIdentifier("drawable/" + pngName, null, _context.getPackageName()));

                imvFlag2.setVisibility(View.VISIBLE);
                if (friend.get_country2().length() > 0) {
                    pngName = "ic_flag_flat_" + friend.get_country2().trim().toLowerCase();
                    imvFlag2.setImageResource(_context.getResources().getIdentifier("drawable/" + pngName, null, _context.getPackageName()));
                } else {
                    imvFlag2.setVisibility(View.GONE);
                }
            }
        } else {    // group chatting

            imvUserPhoto.setVisibility(View.GONE);
            fltGroupPhoto.setVisibility(View.VISIBLE);

            GroupEntity groupEntity = Commons.g_user.getGroup(room.get_name());

            if (groupEntity != null && groupEntity.get_groupNickname().length() > 0) {
                txvChattingUserName.setText(groupEntity.get_groupNickname() + room.get_displayCount());
            } else {
                txvChattingUserName.setText(room.get_displayName() + room.get_displayCount());
            }

            if (room.get_recentContent().contains(Constants.KEY_LEAVEROOM_MARKER)) {

                int dolPos = room.get_recentContent().lastIndexOf("$");
                String name = room.get_recentContent().substring(0, dolPos);
                txvChattingMessage.setText(name +  _context.getString(R.string.leave_room));

            } else if (room.get_recentContent().contains(Constants.KEY_DELEGATE_MARKER)) {

                int dolPos = room.get_recentContent().lastIndexOf("$");
                String roomname = room.get_recentContent().substring(0, dolPos);
                dolPos = roomname.lastIndexOf("$");
                String name = roomname.substring(0, dolPos);
                txvChattingMessage.setText(name + _context.getString(R.string.become_groupowner));

            } else if (room.get_recentContent().contains(Constants.KEY_INVITE_MARKER)) {
                int dolPos = room.get_recentContent().lastIndexOf("$");
                String name = room.get_recentContent().substring(0, dolPos);
                txvChattingMessage.setText(name +  _context.getString(R.string.invited_toroom));

            } else if (room.get_recentContent().contains(Constants.KEY_BANISH_MARKER)) {
                int dolPos = room.get_recentContent().lastIndexOf("$");
                String roomname = room.get_recentContent().substring(0, dolPos);
                dolPos = roomname.lastIndexOf("$");
                String name = roomname.substring(0, dolPos);
                txvChattingMessage.setText(name +  _context.getString(R.string.banish_fromroom));

            }else if (room.get_recentContent().contains(Constants.KEY_REQUEST_MARKER)) {

                int dolPos = room.get_recentContent().lastIndexOf("$");
                String roomname = room.get_recentContent().substring(0, dolPos);
                dolPos = roomname.lastIndexOf("$");
                String name = roomname.substring(0, dolPos);
                txvChattingMessage.setText(name + _context.getString(R.string.group_request_message));

            }else if (room.get_recentContent().contains(Constants.KEY_ADD_MARKER)) {

                int dolPos = room.get_recentContent().lastIndexOf("$");
                String roomname = room.get_recentContent().substring(0, dolPos);
                dolPos = roomname.lastIndexOf("$");
                String name = roomname.substring(0, dolPos);
                txvChattingMessage.setText(name + _context.getString(R.string.add_toroom));

            } else {
                txvChattingMessage.setText(room.get_recentContent());
            }

            txvChattingTime.setText(Commons.getChattingDisplayTime(room.get_recentTime()));

            if (room.get_recentCounter() > 0) {
                txvChattingStateNumber.setText(String.valueOf(room.get_recentCounter()));
                txvChattingStateNumber.setVisibility(View.VISIBLE);
            } else {
                txvChattingStateNumber.setVisibility(View.INVISIBLE);
            }

            if (groupEntity != null) {

                if (groupEntity.get_groupProfileUrl().length() > 0) {

                    imvGroupPhoto.setVisibility(View.VISIBLE);
                    lytGroupPhoto.setVisibility(View.GONE);
                    Glide.with(_context).load(groupEntity.get_groupProfileUrl()).placeholder(R.drawable.img_group).error(R.drawable.img_group).into(imvGroupPhoto);

                } else {

                    if (groupEntity.get_profileUrls().size() > 0) {

                        imvGroupPhoto.setVisibility(View.GONE);
                        lytGroupPhoto.setVisibility(View.VISIBLE);

                        ImageView[] imageViews = {imvGroupPhoto1, imvGroupPhoto2, imvGroupPhoto3, imvGroupPhoto4};
                        for (int i = 0; i < 4; i++) {

                            if (i < groupEntity.get_profileUrls().size()) {
                                Glide.with(_context).load(groupEntity.get_profileUrls().get(i)).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(imageViews[i]);
                            } else {
                                imageViews[i].setImageDrawable(new ColorDrawable(0xffd5d5d5));
                            }
                        }

                    } else {
                        imvGroupPhoto.setVisibility(View.VISIBLE);
                        lytGroupPhoto.setVisibility(View.GONE);
                        Glide.with(_context).load(groupEntity.get_groupProfileUrl()).placeholder(R.drawable.img_group).error(R.drawable.img_group).into(imvGroupPhoto);
                    }
                }

                String pngName = "ic_flag_flat_" + groupEntity.get_country().trim().toLowerCase();
                imvFlag.setImageResource(_context.getResources().getIdentifier("drawable/" + pngName, null, _context.getPackageName()));
            }

            imvFlag2.setVisibility(View.GONE);
        }

    }


}
