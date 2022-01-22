package com.julyseven.wonbridge.adapter;

import android.content.ContentResolver;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.provider.MediaStore;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.julyseven.wonbridge.Chatting.GroupChattingActivity;
import com.julyseven.wonbridge.Chatting.VideoPreviewActivity;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.VideoEntity;

import java.util.ArrayList;

/**
 * Created by IronP on 8/26/2016.
 */
public class VideoGalleryAdapter extends BaseAdapter {

    private GroupChattingActivity _context;
    private int[] _videosId;
    private ArrayList<VideoEntity> _videos;

    public VideoGalleryAdapter(GroupChattingActivity c, ArrayList<VideoEntity> videos) {

        _context = c;
        this._videos = videos;
    }

    public int getCount()
    {
        return _videos.size();
    }
    public Object getItem(int position)
    {
        return position;
    }
    public long getItemId(int position)
    {
        return position;
    }

    public View getView(int position, View convertView, ViewGroup parent)
    {
        final VideoHolder videoHolder;

        if (convertView == null) {

            convertView = LayoutInflater.from(_context).inflate(R.layout.item_video, null);

            videoHolder = new VideoHolder();
            videoHolder.imvPhoto = (ImageView) convertView.findViewById(R.id.imv_photo);
            videoHolder.txvDuration = (TextView) convertView.findViewById(R.id.txv_duration);

            convertView.setTag(videoHolder);

        } else {

            videoHolder = (VideoHolder) convertView.getTag();
        }

        final VideoEntity videoEntity = _videos.get(position);

        ContentResolver crThumb = _context.getContentResolver();
        BitmapFactory.Options options=new BitmapFactory.Options();
        options.inSampleSize = 1;
        Bitmap curThumb = MediaStore.Video.Thumbnails.getThumbnail(crThumb, videoEntity.get_id(), MediaStore.Video.Thumbnails.MICRO_KIND, options);

        videoHolder.imvPhoto.setImageBitmap(curThumb);

        videoHolder.txvDuration.setText(Commons.getDurationString(videoEntity.get_duration()));

        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                String path = videoEntity.get_path();

                Intent intent = new Intent(_context, VideoPreviewActivity.class);
                intent.putExtra(Constants.KEY_VIDEOPATH, path);
                _context.startActivityForResult(intent, Constants.PICK_FROM_VIDEO);
            }
        });

        return  convertView;

    }


    public class VideoHolder {

        public ImageView imvPhoto;
        public TextView txvDuration;
    }

}