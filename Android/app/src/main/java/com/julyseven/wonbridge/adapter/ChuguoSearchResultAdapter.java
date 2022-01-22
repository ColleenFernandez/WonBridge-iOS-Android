package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.model.ChuGuoCategoryEntity;
import com.julyseven.wonbridge.model.ServiceCategoryEntity;
import com.julyseven.wonbridge.service.ChuGuoDetailActivity;

import java.util.ArrayList;

/**
 * Created by sss on 8/24/2016.
 */
public class ChuguoSearchResultAdapter extends BaseAdapter {

    private Context _context;

    private ArrayList<ChuGuoCategoryEntity> _datas = new ArrayList<>();

    public ChuguoSearchResultAdapter(Context context){

        super();
        this._context = context;

    }


    public void setData(ArrayList<ChuGuoCategoryEntity> data) {

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
            convertView = inflater.inflate(R.layout.item_chuguo_result, viewGroup, false);

            resultHolder.txvResultContent = (TextView) convertView.findViewById(R.id.txv_result_content);
            resultHolder.imvResultImage = (ImageView) convertView.findViewById(R.id.imv_result_photo);

            convertView.setTag(resultHolder);

        } else {
            resultHolder = (ResultHolder) convertView.getTag();
        }


        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(_context, ChuGuoDetailActivity.class);
                _context.startActivity(intent);
            }
        });

        return convertView;

    }

    public class ResultHolder {

        public TextView txvResultContent;
        public ImageView imvResultImage;
    }



}
