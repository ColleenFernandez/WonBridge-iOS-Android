package com.julyseven.wonbridge.register;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.adapter.CountryAdapter;
import com.julyseven.wonbridge.adapter.StringAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.CountryEntity;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Locale;

public class SelectSchoolActivity extends CommonActivity implements View.OnClickListener {

    private ArrayList<String> _allSchools = new ArrayList<>();
    private ArrayList<String> _schools = new ArrayList<>();

    private ListView ui_lstInfo;
    private StringAdapter _adapter;

    EditText ui_edtSearch;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_info);
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.select_school));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_lstInfo = (ListView) findViewById(R.id.lst_infos);

        loadSchools();

        _adapter = new StringAdapter(this);
        ui_lstInfo.setAdapter(_adapter);
        _adapter.setData(_schools);

        ui_lstInfo.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

                Intent intent = new Intent();
                intent.putExtra(Constants.KEY_SCHOOL, _schools.get(position));
                setResult(Activity.RESULT_OK, intent);
                finish();
            }
        });

        ui_edtSearch = (EditText) findViewById(R.id.edt_search);
        ui_edtSearch.addTextChangedListener(new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence s, int start, int before,
                                      int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count,
                                          int after) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                String text = ui_edtSearch.getText().toString()
                        .toLowerCase(Locale.getDefault());
                filter(text);
            }
        });

    }

    private void loadSchools() {

        String json = null;
        try {

            InputStream ins = getResources().openRawResource(
                    getResources().getIdentifier("china_university", "raw", getPackageName()));

            int size = ins.available();

            byte[] buffer = new byte[size];

            ins.read(buffer);
            ins.close();

            json = new String(buffer, "UTF-8");


        } catch (IOException ex) {
            ex.printStackTrace();
        }

        if (json == null)
            return;

        try {
            JSONArray jsonArray = new JSONArray(json);

            for (int i = 0; i < jsonArray.length(); i++) {

                JSONObject one = jsonArray.getJSONObject(i);
                JSONArray jsonSchools = one.getJSONArray("school");

                for (int j = 0; j < jsonSchools.length(); j++) {

                    JSONObject jsonSchool = jsonSchools.getJSONObject(j);
                    _allSchools.add(jsonSchool.getString("name"));
                }

            }


        } catch (Exception ex) {
            ex.printStackTrace();
        }

        _schools.addAll(_allSchools);

    }

    public void filter(String charText) {

        charText = charText.toLowerCase();

        _schools.clear();

        if (charText.length() == 0) {
            _schools.addAll(_allSchools);

        } else {

            for (String school : _allSchools) {

                String value = school.toLowerCase();

                if (value.contains(charText)) {
                    _schools.add(school);
                }
            }
        }

        _adapter.setData(_schools);
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
