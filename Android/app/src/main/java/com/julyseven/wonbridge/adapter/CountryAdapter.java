package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.model.CountryEntity;

import java.util.ArrayList;

/**
 * Created by sss on 8/24/2016.
 */
public class CountryAdapter extends BaseAdapter {

    private CommonActivity _context;

    boolean _isOnlyCountry = false;

    private ArrayList<CountryEntity> _countries = new ArrayList<>();

    public CountryAdapter(CommonActivity context){

        super();
        this._context = context;

    }


    public void setOnlyCountry(boolean yesno) {

        _isOnlyCountry = yesno;
    }

    public void setData(ArrayList<CountryEntity> data) {

        _countries = data;
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return _countries.size();
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

        CountryHolder countryHolder;

        if (convertView == null) {

            countryHolder = new CountryHolder();

            LayoutInflater inflater = (LayoutInflater) _context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_country, viewGroup, false);

            countryHolder.txvCountryName = (TextView) convertView.findViewById(R.id.txv_countryname);
            countryHolder.txvCountryCode = (TextView) convertView.findViewById(R.id.txv_countrycode);

            convertView.setTag(countryHolder);

        } else {
            countryHolder = (CountryHolder) convertView.getTag();
        }

        final CountryEntity countryEntity = _countries.get(position);
        countryHolder.txvCountryName.setText(countryEntity.getCountryName());
        countryHolder.txvCountryCode.setText(countryEntity.getCountryPhoneCode());

        if (_isOnlyCountry)
            countryHolder.txvCountryCode.setVisibility(View.GONE);
        else
            countryHolder.txvCountryCode.setVisibility(View.VISIBLE);

        return convertView;

    }

    public class CountryHolder {

        public TextView txvCountryName;
        public TextView txvCountryCode;
    }



}
