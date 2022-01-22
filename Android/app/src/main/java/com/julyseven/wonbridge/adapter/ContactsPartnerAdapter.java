package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.model.PartnerEntity;

import java.util.ArrayList;

/**
 * Created by sss on 8/24/2016.
 */
public class ContactsPartnerAdapter extends BaseAdapter {

    private Context _context;

    private ArrayList<PartnerEntity> _partnerDatas = new ArrayList<>();
    private ArrayList<PartnerEntity> _partnerAllDatas = new ArrayList<>();

    private boolean _isSearch = false;

    public ContactsPartnerAdapter(Context context){

        super();
        this._context = context;

    }

    public void set_isSearch(boolean _isSearch) {
        this._isSearch = _isSearch;
    }

    public void setContactData(ArrayList<PartnerEntity> data) {

        _partnerAllDatas = data;

        _partnerDatas.clear();
        _partnerDatas.addAll(_partnerAllDatas);
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return _partnerDatas.size();
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

        ContactHolder contactHolder;

        if (convertView == null) {

            contactHolder = new ContactHolder();

            LayoutInflater inflater = (LayoutInflater) _context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_contact_partner, viewGroup, false);

            contactHolder.imvPhoto = (ImageView) convertView.findViewById(R.id.imv_photo);
            contactHolder.txvName = (TextView) convertView.findViewById(R.id.txv_name);
            contactHolder.txvAdd = (TextView) convertView.findViewById(R.id.txv_add);

            convertView.setTag(contactHolder);

        } else {
            contactHolder = (ContactHolder) convertView.getTag();
        }

        if (_isSearch) {
            contactHolder.txvAdd.setVisibility(View.VISIBLE);
        } else {
            contactHolder.txvAdd.setVisibility(View.INVISIBLE);
        }

        return convertView;

    }

    public class ContactHolder{

        public ImageView imvPhoto;
        public TextView txvName;
        public TextView txvAdd;
    }



}
