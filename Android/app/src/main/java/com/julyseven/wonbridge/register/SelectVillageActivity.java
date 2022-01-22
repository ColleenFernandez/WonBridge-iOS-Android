package com.julyseven.wonbridge.register;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.adapter.StringAdapter;
import com.julyseven.wonbridge.adapter.VillageAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import se.emilsjolander.stickylistheaders.StickyListHeadersListView;

public class SelectVillageActivity extends CommonActivity implements View.OnClickListener {

    private ArrayList<String> _cities = new ArrayList<>();

    private StickyListHeadersListView ui_lstInfo;
    private VillageAdapter _adapter;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_village);
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.select_village));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_lstInfo = (StickyListHeadersListView) findViewById(R.id.lst_infos);

        _adapter = new VillageAdapter(this);
        ui_lstInfo.setAdapter(_adapter);
        loadCitys();

    }

    private void loadCitys() {

        String provinces[] = {
                "直辖市","广东省","山东省","江苏省","河南省","河北省","浙江省","陕西省","湖南省","福建省","云南省","四川省","广西省","安徽省","海南省","江西省","湖北省","山西省","辽宁省","台湾","黑龙江省","内蒙古自治区", "贵州省","甘肃省","青海省","新疆","西藏区","吉林省","宁夏"
        };

        String cities[][] = {
                {"北京市","重庆市","天津市","上海市"},
                {"东莞市","广州市","中山市","深圳市","惠州市","江门市","珠海市","汕头市","佛山市","湛江市","河源市","肇庆市","潮州市","清远市","韶关市","揭阳市","阳江市","云浮市","茂名市","梅州市","汕尾市"},
                {"济南市","青岛市","临沂市","济宁市","菏泽市","烟台市","泰安市","淄博市","潍坊市","日照市","威海市","滨州市","东营市","聊城市","德州市","莱芜市","枣庄市"},
                {"苏州市","徐州市","盐城市","无锡市","南京市","南通市","连云港市","常州市","扬州市","镇江市","淮安市","泰州市","宿迁市"},
                {"郑州市","南阳市","新乡市","安阳市","洛阳市","信阳市","平顶山市","周口市","商丘市","开封市","焦作市","驻马店市","濮阳市","三门峡市","漯河市","许昌市","鹤壁市","济源市"},
                {"石家庄市","唐山市","保定市","邯郸市","邢台市","河北区","沧州市","秦皇岛市","张家口市","衡水市","廊坊市","承德市"},
                {"温州市","宁波市","杭州市","台州市","嘉兴市","金华市","湖州市","绍兴市","舟山市","丽水市","衢州市"},
                {"西安市","咸阳市","宝鸡市","汉中市","渭南市","安康市","榆林市","商洛市","延安市","铜川市"},
                {"长沙市","邵阳市","常德市","衡阳市","株洲市","湘潭市","永州市","岳阳市","怀化市","郴州市","娄底市","益阳市","张家界市","湘西州"},
                {"漳州市","泉州市","厦门市","福州市","莆田市","宁德市","三明市","南平市","龙岩市"},
                {"昆明市","红河州","大理州","文山州","德宏州","曲靖市","昭通市","楚雄州","保山市","玉溪市","丽江","临沧地区","思茅","西双版纳州","怒江州","迪庆州"},
                {"成都市","绵阳市","广元市","达州市","南充市","德阳市","广安市","阿坝州","巴中市","遂宁市","内江市","凉山州","攀枝花市","乐山市","自贡市","泸州市","雅安市","宜宾市","资阳市","眉山市","甘孜州"},
                {"贵港市","玉林市","北海市","南宁市","柳州市","桂林市","梧州市","钦州市","来宾市","河池市","百色市","贺州市","崇左市","防城港市"},
                {"芜湖市","合肥市","六安市","宿州市","阜阳市","安庆市","马鞍山市","蚌埠市","淮北市","淮南市","宣城市","黄山市","铜陵市","亳州市","池州市","巢湖市","滁州市"},
                {"三亚市","海口市","琼海市","文昌市","东方市","昌江县","陵水县","乐东县","五指山市","保亭县","澄迈县","万宁市","儋州市","临高县","白沙县","定安县","琼中县","屯昌县"},
                {"南昌市","赣州市","上饶市","吉安市","九江市","新余市","抚州市","宜春市","景德镇市","萍乡市","鹰潭市"},
                {"武汉市","宜昌市","襄樊市","荆州市","恩施州","孝感市","黄冈市","十堰市","咸宁市","黄石市","仙桃市","随州市","天门市","荆门市","潜江市","鄂州市","神农架林区"},
                {"太原市","大同市","运城市","长治市","晋城市","忻州市","临汾市","吕梁市","晋中市","阳泉市","朔州市"},
                {"大连市","沈阳市","丹东市","辽阳市","葫芦岛市","锦州市","朝阳市","营口市","鞍山市","抚顺市","阜新市","本溪市","盘锦市","铁岭市"},
                {"台北市","高雄市","台中市","新竹市","基隆市","台南市","嘉义市"},
                {"齐齐哈尔市","哈尔滨市","大庆市","佳木斯市","双鸭山市","牡丹江市","鸡西市","黑河市","绥化市","鹤岗市","伊春市","大兴安岭地区","七台河市"},
                {"赤峰市","包头市","通辽市","呼和浩特市","乌海市","鄂尔多斯市","呼伦贝尔市","兴安盟","巴彦淖尔盟","乌兰察布盟","锡林郭勒盟","阿拉善盟"},
                {"贵阳市","黔东南州","黔南州","遵义市","黔西南州","毕节地区","铜仁地区","安顺市","六盘水市"},
                {"兰州市","天水市","庆阳市","武威市","酒泉市","张掖市","陇南地区","白银市","定西地区","平凉市","嘉峪关市","临夏回族自治州","金昌市","甘南州"},
                {"西宁市","海西州","海东地区","海北州","果洛州","玉树州","黄南藏族自治州"},
                {"乌鲁木齐市","伊犁州","昌吉州","石河子市","哈密地区","阿克苏地区","巴音郭楞州","喀什地区","塔城地区","克拉玛依市","和田地区","阿勒泰州","吐鲁番地区","阿拉尔市","博尔塔拉州","五家渠市","克孜勒苏州","图木舒克市"},
                {"拉萨市","山南地区","林芝地区","日喀则地区","阿里地区","昌都地区","那曲地区"},
                {"吉林市","长春市","白山市","白城市","延边州","松原市","辽源市","通化市","四平市"},
                {"银川市","吴忠市","中卫市","石嘴山市","固原市"}
        };

        _adapter.setData(provinces, cities);
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
