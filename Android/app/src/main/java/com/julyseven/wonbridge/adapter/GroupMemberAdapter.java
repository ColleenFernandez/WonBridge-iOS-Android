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
import com.julyseven.wonbridge.model.FriendEntity;

import java.util.ArrayList;

/**
 * Created by JIS on 9/29/2016.
 */

public class GroupMemberAdapter extends BaseAdapter {

    Context _context;
    ArrayList<FriendEntity> _userDatas = new ArrayList<>();

    public GroupMemberAdapter(Context context) {

        super();
        this._context = context;

    }

    public void setDatas(ArrayList<FriendEntity> data) {
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

        GroupMemberAdapter.UserHolder userHolder;

        if (convertView == null){

            LayoutInflater inflater = (LayoutInflater)_context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_membergrid, viewGroup, false);

            userHolder = new GroupMemberAdapter.UserHolder();

            userHolder.imvPhoto = (ImageView)convertView.findViewById(R.id.image_one);
            userHolder.txvName = (TextView)convertView.findViewById(R.id.txv_name);

            convertView.setTag(userHolder);

        }else {
            userHolder = (GroupMemberAdapter.UserHolder)convertView.getTag();
        }

        userHolder.imvPhoto.setImageBitmap(null);

        FriendEntity user = _userDatas.get(position);

        if (user.get_name().equals("+")) {
            userHolder.imvPhoto.setImageResource(R.drawable.button_invite_group);
            userHolder.txvName.setText("");
        } else if (user.get_name().equals("-")) {
            userHolder.imvPhoto.setImageResource(R.drawable.button_banish_group);
            userHolder.txvName.setText("");
        } else {
            Glide.with(_context).load(user.get_photoUrl()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(userHolder.imvPhoto);
            userHolder.txvName.setText(user.get_name());
        }

        return convertView;
    }

    public class UserHolder{

        public ImageView imvPhoto;
        public TextView txvName;
    }
}
