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
import com.julyseven.wonbridge.Chatting.GroupChattingActivity;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.ServiceCategoryEntity;

import java.util.ArrayList;

/**
 * Created by sss on 8/24/2016.
 */
public class ServiceSearchResultAdapter extends BaseAdapter {

    private Context _context;

    private ArrayList<ServiceCategoryEntity> _datas = new ArrayList<>();

    public ServiceSearchResultAdapter(Context context){

        super();
        this._context = context;

    }


    public void setData(ArrayList<ServiceCategoryEntity> data) {

        _datas = data;
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return _datas.size();
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

        ResultHolder resultHolder;

        if (convertView == null) {

            resultHolder = new ResultHolder();

            LayoutInflater inflater = (LayoutInflater) _context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_service_result, viewGroup, false);

            resultHolder.imvPhoto = (ImageView) convertView.findViewById(R.id.imv_user_photo);
            resultHolder.txvResultName = (TextView) convertView.findViewById(R.id.txv_result_name);
            resultHolder.txvResultContent = (TextView) convertView.findViewById(R.id.txv_result_content);
            resultHolder.imvResultImage = (ImageView) convertView.findViewById(R.id.imv_result_photo);
            resultHolder.imvFlag = (ImageView) convertView.findViewById(R.id.imv_flag);

            convertView.setTag(resultHolder);

        } else {
            resultHolder = (ResultHolder) convertView.getTag();
        }

        ServiceCategoryEntity entity = _datas.get(position);

        resultHolder.txvResultName.setText(entity.get_categoryName());
        resultHolder.txvResultContent.setText(entity.get_description());
        Glide.with(_context).load(entity.get_imageUrl()).into(resultHolder.imvResultImage);

        String pngName = "ic_flag_flat_" + entity.get_country().trim().toLowerCase();
        resultHolder.imvFlag.setImageResource(_context.getResources().getIdentifier("drawable/" + pngName, null, _context.getPackageName()));

        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(_context, GroupChattingActivity.class);
                intent.putExtra(Constants.KEY_ONLINE_SERVICE, true);
                _context.startActivity(intent);
            }
        });

        return convertView;

    }

    public class ResultHolder {

        public ImageView imvPhoto;
        public TextView txvResultName;
        public TextView txvResultContent;
        public ImageView imvResultImage;
        public ImageView imvFlag;
    }



}
