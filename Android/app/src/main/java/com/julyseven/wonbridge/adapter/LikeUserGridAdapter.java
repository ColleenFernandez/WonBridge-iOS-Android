package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.model.FriendEntity;

import java.util.ArrayList;

/**
 * Created by sss on 8/22/2016.
 */
public class LikeUserGridAdapter extends BaseAdapter {

    Context _context;
    ArrayList<FriendEntity> _userDatas = new ArrayList<>();

    public LikeUserGridAdapter(Context context) {

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

        UserHolder userHolder;

        if (convertView == null){

            LayoutInflater inflater = (LayoutInflater)_context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_like_users, viewGroup, false);

            userHolder = new UserHolder();

            userHolder.imvPhoto = (ImageView)convertView.findViewById(R.id.imv_image);

            convertView.setTag(userHolder);

        }else {
            userHolder = (UserHolder)convertView.getTag();
        }

        userHolder.imvPhoto.setImageBitmap(null);

        FriendEntity user = _userDatas.get(position);
        Glide.with(_context).load(user.get_photoUrl()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(userHolder.imvPhoto);


        return convertView;
    }

    public class UserHolder{

        public ImageView imvPhoto;
    }
}
