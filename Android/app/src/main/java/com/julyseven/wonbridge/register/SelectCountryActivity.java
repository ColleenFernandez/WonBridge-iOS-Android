package com.julyseven.wonbridge.register;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.CountryAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.CountryEntity;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Locale;

public class SelectCountryActivity extends CommonActivity implements View.OnClickListener {

    private ArrayList<CountryEntity> _countries = new ArrayList<>();

    private ListView ui_lstCountries;
    private CountryAdapter _adapter;

    boolean _isOnlyCountry = false;
    boolean _isChangeCountry2 = false;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_country);

        _isOnlyCountry = getIntent().getBooleanExtra(Constants.KEY_ONLY_COUNTRY, false);
        _isChangeCountry2 = getIntent().getBooleanExtra(Constants.KEY_CHANGE_COUNTRY2, false);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.select_country));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_lstCountries = (ListView) findViewById(R.id.lst_countries);

        loadCountries();

        _adapter = new CountryAdapter(this);
        ui_lstCountries.setAdapter(_adapter);
        _adapter.setOnlyCountry(_isOnlyCountry);
        _adapter.setData(_countries);

        ui_lstCountries.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {


                if (!_isChangeCountry2) {
                    Intent intent = new Intent();
                    intent.putExtra(Constants.KEY_COUNTRY, _countries.get(position));
                    setResult(Activity.RESULT_OK, intent);
                    finish();
                } else {
                    changeCountry2(_countries.get(position));
                }
            }
        });

    }

    private void loadCountries() {

        String[] phoneCodesList = this.getResources().getStringArray(R.array.CountryPhoneCodesList);

        for (String countryCode : phoneCodesList) {

            String[] itemText = countryCode.split(",");

            Locale loc = new Locale("", itemText[1]);
            String country = loc.getDisplayCountry();

            _countries.add(new CountryEntity(country, itemText[1], itemText[0]));
        }

        Collections.sort(_countries, new Comparator<CountryEntity>() {
                    @Override
                    public int compare(CountryEntity lhs, CountryEntity rhs) {
                        return lhs.getCountryName().compareToIgnoreCase(rhs.getCountryName());
                    }
                }

        );

    }

    public void changeCountry2(final CountryEntity country)  {

        showProgress();

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETCOUNTRY2;

        String params = String.format("/%d/%s", Commons.g_user.get_idx(), country.getCountryCode());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                closeProgress();
                Commons.g_user.set_country2(country.getCountryCode());
                setResult(Activity.RESULT_OK);
                finish();
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                closeProgress();
                showAlertDialog(getString(R.string.error));
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);


    }


    private void onBack() {
        finish();
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                onBack();
                break;



        }

    }


}
