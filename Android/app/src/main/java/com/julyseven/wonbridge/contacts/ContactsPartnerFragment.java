package com.julyseven.wonbridge.contacts;

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
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.adapter.ContactsPartnerAdapter;
import com.julyseven.wonbridge.base.BaseFragment;
import com.julyseven.wonbridge.model.PartnerEntity;

import java.util.ArrayList;


/**
 * Created by sss on 8/24/2016.
 */
public class ContactsPartnerFragment extends BaseFragment implements View.OnClickListener {

    RelativeLayout ui_rltSearch;
    LinearLayout ui_lytAddPartner;
    EditText ui_edtSearch;

    ListView ui_lstContacts;
    ContactsPartnerAdapter _adapter = null;

    Context _context;

    private ArrayList<PartnerEntity> _allPatners = new ArrayList<>();

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        this._context = getActivity();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_contacts_partner, container, false);

        ui_rltSearch = (RelativeLayout) view.findViewById(R.id.rlt_search);
        ui_rltSearch.setVisibility(View.INVISIBLE);

        ui_lytAddPartner = (LinearLayout) view.findViewById(R.id.lyt_add_partner);
        ui_lytAddPartner.setOnClickListener(this);

        ui_lstContacts = (ListView) view.findViewById(R.id.lst_contacts_partner);
        _adapter = new ContactsPartnerAdapter(_context);
        ui_lstContacts.setAdapter(_adapter);

        ImageView imvSearch = (ImageView) view.findViewById(R.id.imv_search);
        imvSearch.setOnClickListener(this);

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

            }
        });

        ui_edtSearch.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    return true;
                }
                return false;
            }
        });

        setPartners();

        return view;
    }

    public void setPartners() {

        _allPatners.clear();

        for (int i = 0; i < 10; i++) {
            PartnerEntity entity = new PartnerEntity();
            _allPatners.add(entity);
        }

        _adapter.setContactData(_allPatners);

    }


    public void hideKeyboard() {

        InputMethodManager imm = (InputMethodManager) _context.getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtSearch.getWindowToken(), 0);
    }



    @Override
    public void onClick(View v) {

        switch (v.getId()) {

            case R.id.imv_search:
                break;


            case R.id.lyt_add_partner:
                ui_lytAddPartner.setVisibility(View.INVISIBLE);
                ui_rltSearch.setVisibility(View.VISIBLE);
                break;

        }


    }

}
