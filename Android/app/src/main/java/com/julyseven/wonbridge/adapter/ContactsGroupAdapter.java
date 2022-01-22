package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.Chatting.GroupChattingActivity;
import com.julyseven.wonbridge.Chatting.GroupProfileActivity;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.BaseFragment;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.GroupEntity;
import com.julyseven.wonbridge.model.RoomEntity;
import com.julyseven.wonbridge.timeline.TimelineGroupFragment;

import java.util.ArrayList;

/**
 * Created by sss on 8/24/2016.
 */
public class ContactsGroupAdapter extends BaseAdapter {

    private Context _context;
    private boolean _isSearch = false;
    BaseFragment _fragment;

    private ArrayList<GroupEntity> _contactDatas = new ArrayList<>();

    public ContactsGroupAdapter(Context context, BaseFragment fragment){

        super();
        this._context = context;
        _fragment = fragment;

    }

    public void set_isSearch(boolean _isSearch) {
        this._isSearch = _isSearch;
    }

    public void setContactData(ArrayList<GroupEntity> data) {

        _contactDatas = data;
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return _contactDatas.size();
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
    public View getView(int position, View convertView, ViewGroup viewGroup) {

        GroupHodler contactHolder;

        if (convertView == null) {

            contactHolder = new GroupHodler();

            LayoutInflater inflater = (LayoutInflater) _context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_contact_group, viewGroup, false);

            contactHolder.imvPhoto = (ImageView) convertView.findViewById(R.id.imv_photo);
            contactHolder.imvPhoto1 = (ImageView) convertView.findViewById(R.id.imv_photo1);
            contactHolder.imvPhoto2 = (ImageView) convertView.findViewById(R.id.imv_photo2);
            contactHolder.imvPhoto3 = (ImageView) convertView.findViewById(R.id.imv_photo3);
            contactHolder.imvPhoto4 = (ImageView) convertView.findViewById(R.id.imv_photo4);
            contactHolder.lytPhoto = (LinearLayout) convertView.findViewById(R.id.lyt_photo);
            contactHolder.txvName = (TextView) convertView.findViewById(R.id.txv_name);
            contactHolder.txvAdd = (TextView) convertView.findViewById(R.id.txv_add);
            contactHolder.txvDate = (TextView) convertView.findViewById(R.id.txv_date);
            contactHolder.imvFlag = (ImageView) convertView.findViewById(R.id.imv_flag);

            convertView.setTag(contactHolder);

        } else {
            contactHolder = (GroupHodler) convertView.getTag();
        }

        final GroupEntity group = _contactDatas.get(position);

        contactHolder.txvName.setText(group.get_groupNickname() + "(" + group.getMemeberCount() + ")");
        contactHolder.txvDate.setText(_context.getString(R.string.build_date) + ": " + group.get_regDate());

        if (_isSearch) {

            contactHolder.txvAdd.setVisibility(View.VISIBLE);

            if (Commons.g_user.get_groupList().contains(group)) {
                contactHolder.txvAdd.setSelected(false);
                contactHolder.txvAdd.setText(_context.getString(R.string.already_added));
                contactHolder.txvAdd.setVisibility(View.GONE);
            } else {

                if (group.is_isRequested()) {
                    contactHolder.txvAdd.setSelected(false);
                    contactHolder.txvAdd.setText(_context.getString(R.string.request));
                } else {

                    contactHolder.txvAdd.setSelected(true);
                    contactHolder.txvAdd.setText(_context.getString(R.string.add));
                }
            }
        } else {
            contactHolder.txvAdd.setVisibility(View.INVISIBLE);
        }

        if (group.get_groupProfileUrl().length() > 0) {
            contactHolder.imvPhoto.setVisibility(View.VISIBLE);
            contactHolder.lytPhoto.setVisibility(View.GONE);
            Glide.with(_context).load(group.get_groupProfileUrl()).placeholder(R.drawable.img_group).error(R.drawable.img_group).into(contactHolder.imvPhoto);

        } else {

            if (group.get_profileUrls().size() > 0) {

                contactHolder.imvPhoto.setVisibility(View.GONE);
                contactHolder.lytPhoto.setVisibility(View.VISIBLE);

                ImageView[] imageViews = {contactHolder.imvPhoto1, contactHolder.imvPhoto2, contactHolder.imvPhoto3, contactHolder.imvPhoto4};
                for (int i = 0; i < 4; i++) {

                    if (i < group.get_profileUrls().size()) {
                        Glide.with(_context).load(group.get_profileUrls().get(i)).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(imageViews[i]);
                    } else {
                        imageViews[i].setImageDrawable(new ColorDrawable(0xffd5d5d5));
                    }
                }

            } else {
                contactHolder.imvPhoto.setVisibility(View.VISIBLE);
                contactHolder.lytPhoto.setVisibility(View.GONE);
                Glide.with(_context).load(group.get_groupProfileUrl()).placeholder(R.drawable.img_group).error(R.drawable.img_group).into(contactHolder.imvPhoto);
            }

        }

        String pngName = "ic_flag_flat_" + group.get_country().trim().toLowerCase();
        contactHolder.imvFlag.setImageResource(_context.getResources().getIdentifier("drawable/" + pngName, null, _context.getPackageName()));

        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                // if my group go to chatting
                if (Commons.g_user.get_groupList().contains(group)) {

                    Intent intent = new Intent(_context, GroupChattingActivity.class);
                    intent.putExtra(Constants.KEY_ROOM, group.get_groupName());
                    _context.startActivity(intent);

                } else {

                    Intent intent = new Intent(_context, GroupProfileActivity.class);
                    intent.putExtra(Constants.KEY_GROUP, group);
                    _context.startActivity(intent);
                }
            }
        });

        contactHolder.txvAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (_fragment instanceof TimelineGroupFragment) {
                    ((TimelineGroupFragment) _fragment).showRequestGroupDiag(group);
                }
            }
        });


        return convertView;

    }

    public class GroupHodler {

        public ImageView imvPhoto, imvFlag, imvPhoto1, imvPhoto2, imvPhoto3, imvPhoto4;
        public TextView txvName;
        public TextView txvDate;
        public TextView txvAdd;
        public LinearLayout lytPhoto;
    }



}
