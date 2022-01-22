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

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.adapter.ChuGuoSearchAdapter;
import com.julyseven.wonbridge.adapter.ChuguoSearchResultAdapter;
import com.julyseven.wonbridge.base.CommonServiceFragment;
import com.julyseven.wonbridge.model.ChuGuoCategoryEntity;
import com.julyseven.wonbridge.model.ChuGuoItemEntity;

import java.util.ArrayList;

/**
 * Created by sss on 8/24/2016.
 */
public class ChuGuoFragment extends CommonServiceFragment implements View.OnClickListener {

    Context _context;

    GridView ui_gridView;

    ListView ui_lstSearchResult;
    private ChuGuoSearchAdapter _searchAdapter;
    private ChuguoSearchResultAdapter _resultAdapter;

    EditText ui_edtSearch;

    ArrayList<ChuGuoCategoryEntity> _results = new ArrayList<>();

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        this._context = getActivity();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_service_search, container, false);

        ui_gridView = (GridView)view.findViewById(R.id.gdv_search);
        _searchAdapter = new ChuGuoSearchAdapter(_context, this);
        ui_gridView.setAdapter(_searchAdapter);

        int strIds[] = {R.string.chuguo_search_1, R.string.chuguo_search_2, R.string.chuguo_search_3, R.string.chuguo_search_4,
                R.string.chuguo_search_5, R.string.chuguo_search_6, R.string.chuguo_search_7, R.string.chuguo_search_8};

        int imgIds[] = {R.drawable.icon_nkow, R.drawable.icon_visa, R.drawable.icon_country, R.drawable.icon_verify,
                R.drawable.icon_flight, R.drawable.icon_cash, R.drawable.icon_train, R.drawable.icon_hotel};

        ArrayList<ChuGuoItemEntity> items = new ArrayList<>();
        for (int i = 0; i < 8; i++) {
            ChuGuoItemEntity item = new ChuGuoItemEntity(getString(strIds[i]), imgIds[i]);
            items.add(item);
        }
        _searchAdapter.setDatas(items);


        ui_lstSearchResult = (ListView) view.findViewById(R.id.lst_search);
        _resultAdapter = new ChuguoSearchResultAdapter(_context);
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

        return view;
    }


    @Override
    public void search() {

        hideKeyboard();

        ui_gridView.setVisibility(View.GONE);
        ui_lstSearchResult.setVisibility(View.VISIBLE);

        for (int i = 0; i < 2; i++) {
            ChuGuoCategoryEntity entity = new ChuGuoCategoryEntity();
            _results.add(entity);
        }

        _resultAdapter.setData(_results);

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
