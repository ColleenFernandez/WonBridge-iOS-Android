package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.message.SelectFriendActivity;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.mypage.ManageFriendActivity;

import java.util.ArrayList;

/**
 * Created by IronP on 8/29/2016.
 */
public class FriendSelectAdapter extends BaseAdapter {

    CommonActivity _context;
    private ArrayList<FriendEntity> _userDatas = new ArrayList<>();

    boolean _isSelectOne = false;

    public FriendSelectAdapter(CommonActivity context) {

        super();
        this._context = context;

    }

    public void set_isSelectOne(boolean one) {
        _isSelectOne = one;
    }

    public void setUsers(ArrayList<FriendEntity> data) {

        _userDatas = data;
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

        final UserHolder userHolder;

        if (convertView == null){

            LayoutInflater inflater = (LayoutInflater)_context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_usergrid, viewGroup, false);

            userHolder = new UserHolder();

            userHolder.imvPhoto = (ImageView)convertView.findViewById(R.id.image_one);
            userHolder.imvSex = (ImageView)convertView.findViewById(R.id.imv_userlist_sexicon);
            userHolder.txvName = (TextView)convertView.findViewById(R.id.txv_userlist_name);
            userHolder.txvTime = (TextView)convertView.findViewById(R.id.txv_userlist_time);
            userHolder.txvDistance  = (TextView)convertView.findViewById(R.id.txv_userlist_distance);
            userHolder.imvCheckBox = (ImageView) convertView.findViewById(R.id.chk_box);
            userHolder.imvCheckBox.setVisibility(View.VISIBLE);
            convertView.setTag(userHolder);

        }else {

            userHolder = (UserHolder)convertView.getTag();
        }

        userHolder.imvPhoto.setImageBitmap(null);

        final FriendEntity friend = _userDatas.get(position);

        Glide.with(_context).load(friend.get_photoUrl()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(userHolder.imvPhoto);

        userHolder.txvName.setText(friend.get_name());

        userHolder.txvTime.setText(Commons.getDisplayLocalTimeString(friend.get_lastLogin()));
        userHolder.imvSex.setSelected(friend.get_sex() == 1);
        userHolder.txvDistance.setText(friend.getDistance(_context) + "km");
        userHolder.imvCheckBox.setSelected(friend.is_isSelected());

        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (_isSelectOne) {
                    ((SelectFriendActivity) _context).selectOneFriend(friend);
                } else {

                    userHolder.imvCheckBox.setSelected(!userHolder.imvCheckBox.isSelected());
                    friend.set_isSelected(userHolder.imvCheckBox.isSelected());

                    if (_context instanceof SelectFriendActivity) {

                        if (friend.is_isSelected()) {
                            ((SelectFriendActivity) _context).plusFriend();
                        } else {
                            ((SelectFriendActivity) _context).minusFriend();
                        }
                    } else if (_context instanceof ManageFriendActivity) {

                        if (friend.is_isSelected()) {
                            ((ManageFriendActivity) _context).plusFriend();
                        } else {
                            ((ManageFriendActivity) _context).minusFriend();
                        }
                    }
                }

            }
        });


        return convertView;
    }

    public class UserHolder{

        public ImageView imvPhoto;
        public ImageView imvSex;
        public TextView txvName;
        public TextView txvTime;
        public TextView txvDistance;
        public ImageView imvCheckBox;
    }
}
