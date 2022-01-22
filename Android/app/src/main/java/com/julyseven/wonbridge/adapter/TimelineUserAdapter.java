package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.timeline.UserProfileActivity;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

/**
 * Created by sss on 8/22/2016.
 */
public class TimelineUserAdapter extends BaseAdapter {

    Context _context;
    ArrayList<FriendEntity> _userDatas = new ArrayList<>();

    public TimelineUserAdapter(Context context) {

        super();
        this._context = context;

    }

    public void setDatas(ArrayList<FriendEntity> data) {
        _userDatas = data;

//        Collections.sort(_userDatas, new Comparator<FriendEntity>() {
//            public int compare(FriendEntity o1, FriendEntity o2) {
//                return new Integer(o1.getDistance(_context)).compareTo(new Integer(o2.getDistance(_context)));
//            }
//        });

        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return _userDatas.size();
    }

    @Override
    public Object getItem(int position) {
        return _userDatas.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup viewGroup) {

        UserHolder userHolder;

        if (convertView == null){

            LayoutInflater inflater = (LayoutInflater)_context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_timeline_user, viewGroup, false);

            userHolder = new UserHolder();

            userHolder.imvPhoto = (ImageView)convertView.findViewById(R.id.image_one);
            userHolder.imvSex = (ImageView)convertView.findViewById(R.id.imv_userlist_sexicon);
            userHolder.txvName = (TextView)convertView.findViewById(R.id.txv_userlist_name);
            userHolder.txvTime = (TextView)convertView.findViewById(R.id.txv_userlist_time);
            userHolder.txvDistance  = (TextView)convertView.findViewById(R.id.txv_userlist_distance);
            userHolder.imvFlag = (ImageView) convertView.findViewById(R.id.imv_flag);
            userHolder.imvFlag2 = (ImageView) convertView.findViewById(R.id.imv_flag2);

            convertView.setTag(userHolder);

        }else {
            userHolder = (UserHolder)convertView.getTag();
        }

        userHolder.imvPhoto.setImageBitmap(null);

        final FriendEntity friend = _userDatas.get(position);

        Glide.with(_context).load(friend.get_photoUrl()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(userHolder.imvPhoto);

        userHolder.txvName.setText(friend.get_name());
        userHolder.imvSex.setSelected(friend.get_sex() == 1);
        userHolder.txvTime.setText(Commons.getDisplayLocalTimeString(friend.get_lastLogin()));
        userHolder.txvDistance.setText(friend.getDistance(_context) + "km");

        String pngName = "ic_flag_flat_" + friend.get_country().trim().toLowerCase();
        userHolder.imvFlag.setImageResource(_context.getResources().getIdentifier("drawable/" + pngName, null, _context.getPackageName()));

        if (friend.get_country2().length() > 0) {
            userHolder.imvFlag2.setVisibility(View.VISIBLE);
            pngName = "ic_flag_flat_" + friend.get_country2().trim().toLowerCase();
            userHolder.imvFlag2.setImageResource(_context.getResources().getIdentifier("drawable/" + pngName, null, _context.getPackageName()));
        } else {
            userHolder.imvFlag2.setVisibility(View.GONE);
        }

        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(_context, UserProfileActivity.class);
                intent.putExtra(Constants.KEY_FRIEND, friend);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                _context.startActivity(intent);
            }
        });

        return convertView;
    }

    public class UserHolder{

        public ImageView imvPhoto, imvFlag, imvFlag2;;
        public ImageView imvSex;
        public TextView txvName;
        public TextView txvTime;
        public TextView txvDistance;
    }
}
