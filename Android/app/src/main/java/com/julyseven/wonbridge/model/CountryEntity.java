package com.julyseven.wonbridge.model;

import java.io.Serializable;

/**
 * Created by JIS on 9/28/2016.
 */

public class CountryEntity implements Serializable{

    public String getCountryPhoneCode() {
        return _countryPhoneCode;
    }

    public String getCountryCode() {
        return _countryCode;
    }

    public String getCountryName() {
        return _countryName;
    }

    public CountryEntity(String countryName, String countryCode, String phoneCode) {
        _countryName = countryName;
        _countryCode = countryCode;
        _countryPhoneCode = phoneCode;
    }

    private String _countryName = "";
    private String _countryPhoneCode = "";
    private String _countryCode = "";



}
