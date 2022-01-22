package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.model.FriendEntity;

import java.util.ArrayList;

/**
 * Created by Asaf on 1/19/2016.
 */

public class TimelineLikeUserAdapter extends RecyclerView.Adapter<TimelineLikeUserAdapter.ImageHolder> {

    private ArrayList<FriendEntity> _likeUsers = new ArrayList<>();
    private Context _context;

    public TimelineLikeUserAdapter(Context context) {

        this._context = context;
    }



    @Override
    public ImageHolder onCreateViewHolder(ViewGroup viewGroup, final int position) {

        View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_timeline_likeuser, viewGroup, false);

        ImageHolder viewHolder = new ImageHolder(view);
        return viewHolder;
    }


    public void setDatas(ArrayList<FriendEntity> datas) {
        _likeUsers = datas;
        notifyDataSetChanged();
    }

    @Override
    public void onBindViewHolder(ImageHolder viewHolder, int i) {

        FriendEntity friend = _likeUsers.get(i);
        Glide.with(_context).load(friend.get_photoUrl()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(viewHolder.imvPhoto);

    }

    @Override
    public int getItemCount() {
        return (null != _likeUsers ? _likeUsers.size() : 0);
    }


    public class ImageHolder extends RecyclerView.ViewHolder {

        ImageView imvPhoto;

        public ImageHolder(View view) {

            super(view);
            imvPhoto = (ImageView) view.findViewById(R.id.imv_image);
        }
    }


}
