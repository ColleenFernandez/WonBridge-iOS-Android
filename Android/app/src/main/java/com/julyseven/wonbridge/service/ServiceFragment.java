package com.julyseven.wonbridge.service;

import android.content.Context;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.GridView;
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
import com.julyseven.wonbridge.adapter.ServiceSearchAdapter;
import com.julyseven.wonbridge.adapter.ServiceSearchResultAdapter;
import com.julyseven.wonbridge.base.CommonServiceFragment;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.ServiceItemEntity;
import com.julyseven.wonbridge.model.ServiceCategoryEntity;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;

/**
 * Created by sss on 8/24/2016.
 */
public class ServiceFragment extends CommonServiceFragment implements View.OnClickListener {

    Context _context;

    GridView ui_gridView;
    ListView ui_lstSearchResult;
    private ServiceSearchAdapter _searchAdapter;
    private ServiceSearchResultAdapter _resultAdapter;

    EditText ui_edtSearch;

    ArrayList<ServiceItemEntity> _categories = new ArrayList<>();
    ArrayList<ServiceCategoryEntity> _results = new ArrayList<>();

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        this._context = getActivity();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_service_search, container, false);

        ui_gridView = (GridView)view.findViewById(R.id.gdv_search);
        _searchAdapter = new ServiceSearchAdapter(_context, this);
        ui_gridView.setAdapter(_searchAdapter);

        ui_lstSearchResult = (ListView) view.findViewById(R.id.lst_search);
        _resultAdapter = new ServiceSearchResultAdapter(_context);
        ui_lstSearchResult.setAdapter(_resultAdapter);
        ui_lstSearchResult.setVisibility(View.GONE);

        ImageView imvSearch = (ImageView) view.findViewById(R.id.imv_search);
        imvSearch.setOnClickListener(this);

        ImageView imvBack = (ImageView) view.findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_edtSearch = (EditText) view.findViewById(R.id.edt_search);
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

                if (s.length() == 0) {
                    ui_gridView.setVisibility(View.VISIBLE);
                    ui_lstSearchResult.setVisibility(View.GONE);
                }
            }
        });

        ui_edtSearch.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {

                    if (ui_edtSearch.getText().length() != 0)
                        search();

                    return true;
                }
                return false;
            }
        });

        getCategories();

        return view;
    }


    public void getCategories() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETSERVICECATEGORIES;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseCategoryResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                error.printStackTrace();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseCategoryResponse(String json) {

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            _categories.clear();

            if (result_code == ReqConst.CODE_SUCCESS) {

                JSONArray categories = response.getJSONArray(ReqConst.RES_CATEGORYINFOS);

                for (int i = 0; i < categories.length(); i++) {

                    JSONObject category = categories.getJSONObject(i);

                    int idx = category.getInt(ReqConst.RES_ID);
                    String name = category.getString(ReqConst.RES_NAME);
                    String fileUrl = category.getString(ReqConst.RES_FILE_URL);

                    ServiceItemEntity item = new ServiceItemEntity(idx, name, fileUrl);
                    _categories.add(item);
                }
            }

            _searchAdapter.setDatas(_categories);

        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    @Override
    public void search() {

        gotoServiceDetail(1);

    }


    public void gotoServiceDetail(int serviceId) {

        hideKeyboard();

        ui_gridView.setVisibility(View.GONE);
        ui_lstSearchResult.setVisibility(View.VISIBLE);

        _results.clear();
        _resultAdapter.setData(_results);

        getSubCategories(serviceId);

    }

    public void getSubCategories(int categoryId) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETSUBCATEGORIES;
        String params = String.format("/%d", categoryId);

        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseSubCategoryResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                error.printStackTrace();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseSubCategoryResponse(String json) {

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            _results.clear();

            if (result_code == ReqConst.CODE_SUCCESS) {

                JSONArray subCategories = response.getJSONArray(ReqConst.RES_SUBCATEGORY);

                for (int i = 0; i < subCategories.length(); i++) {

                    JSONObject subCategory = subCategories.getJSONObject(i);

                    ServiceCategoryEntity entity = new ServiceCategoryEntity();
                    entity.set_categoryName(subCategory.getString(ReqConst.RES_NAME));
                    entity.set_country(subCategory.getString(ReqConst.RES_COUNTRY));
                    entity.set_imageUrl(subCategory.getString(ReqConst.RES_FILE_URL));
                    entity.set_description(subCategory.getString(ReqConst.RES_CONTENT));
                    _results.add(entity);

                }
            }

            _resultAdapter.setData(_results);

        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }


    public void hideKeyboard() {

        InputMethodManager imm = (InputMethodManager) _context.getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtSearch.getWindowToken(), 0);
    }


    @Override
    public void onClick(View v) {

        switch (v.getId()) {

            case R.id.imv_search:

                if (ui_edtSearch.getText().length() != 0)
                    search();

                break;

            case R.id.imv_back:
                ui_gridView.setVisibility(View.VISIBLE);
                ui_lstSearchResult.setVisibility(View.GONE);
                break;


        }
    }
}
