package com.example.selena_wang.frontend;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;


public class homepage extends Activity {

    public static final String url = "http://caravanparty.herokuapp.com/";
    public static final int SUCCESS = 1;
    public static final int ERR_USER_ALREADY_EXISTS = -1;
    public static final int ERR_USER_DOESNT_EXIST = -2;
    public static final int ERR_USER_NO_REQUEST = -3;

    private static boolean active = false;

    public static boolean getActive(){
        return active;
    }

    private static String username;
    private static String user_id;
    private static int[] friend_ids;
    ListView list;

    public static String get_username(){return username;}
    private void set_username(String name){username = name;}

    public static String get_user_id(){
        return user_id;
    }
    private void set_user_id(String id){
        user_id = id;
    }

    public static int [] getFriend_ids(){return friend_ids;}
    private void setFriend_ids(int[] ids){friend_ids = ids;}

    private Button past;
    private Button create;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.homepage_layout);
        list = (ListView) findViewById(R.id.home_list);
        TextView user = (TextView) findViewById(R.id.username);
        Button toCurrentCaravan = (Button) findViewById(R.id.caravan_button_home);
        TextView currentCaravan = (TextView) findViewById(R.id.caravan_info);
        Intent intent = getIntent();
        if(intent!=null) {
            if (intent.hasExtra("user")) {
                set_username(intent.getStringExtra("username"));
            }
            if(intent.hasExtra("user_id")){
                set_user_id(intent.getStringExtra("user_id"));
            }
            if(intent.hasExtra("friend_ids")){
                setFriend_ids(intent.getIntArrayExtra("friend_ids"));
            }
        }
        user.setText("Welcome " + get_username() + "with id" + get_user_id() + "!");
        user.setTextSize(20);

        toCurrentCaravan.setClickable(false);
        currentCaravan.setText("No Current Caravan");
    }

    @Override
    protected void onRestart(){
        super.onRestart();
        active = true;
        createListView();
    }

    @Override
    public void onStop() {
        super.onStop();
        active = false;
    }

    private void createListView(){
        new MyAsyncTask().execute("list");

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.action_bar,menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if(id==R.id.home){

        }
        else if (id == R.id.friend_icon) {
            Intent intent = new Intent(this,friends.class);
            if(friends.getActive()){
                intent.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            }
            startActivity(intent);
        }else if (id == R.id.caravan_icon){
            Intent intent = new Intent(this,caravan_map.class);
            if(caravan_map.getActive()){
                intent.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            }
            startActivity(intent);
        }else if(id == R.id.create_icon){
            Intent intent = new Intent(this,create_caravan.class);
            if(create_caravan.getActive()){
                intent.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            }
            startActivity(intent);
        }
        return super.onOptionsItemSelected(item);
    }

    private class MyAsyncTask extends AsyncTask<String, Integer, Double> {
        private String username;
        private String password;

        @Override
        protected Double doInBackground(String... params) {
            if(params[0].equals("list")){
                createList(params[0]);
            }
            return null;
        }

        private void createList(String parameter){
            String friend_url = "users/" + get_user_id() + "/friends/requests";
            String caravans_url = "users/" + get_user_id() + "/caravans";
            HttpClient httpclient = new DefaultHttpClient();
            HttpPost  httpPost_friend = new HttpPost(url + friend_url);
            HttpPost  httpPost_caravans = new HttpPost(url+caravans_url);
            List data1 = new ArrayList();
            List data2 = new ArrayList();
            data1.add(get_user_id());
            data2.add(get_user_id());
            try{
                httpPost_friend.setEntity(new UrlEncodedFormEntity(data1));
                httpPost_caravans.setEntity(new UrlEncodedFormEntity(data2));

            }catch (UnsupportedEncodingException e){
                e.printStackTrace();
            }
            try{
                HttpResponse response_friend = httpclient.execute(httpPost_friend);
                HttpResponse response_caravans = httpclient.execute(httpPost_caravans);
                try{
                    JSONObject json_friend = new JSONObject(EntityUtils.toString(response_friend.getEntity()));
                    JSONObject json_caravan = new JSONObject(EntityUtils.toString(response_caravans.getEntity()));
                    create_listView(json_friend, json_caravan);
                }catch(JSONException e){
                    e.printStackTrace();
                }
            }catch (IOException e){
                e.printStackTrace();
            }


        }

        // list structure = [caravan/friend, username/caravan_id, caravan destination, caravan members]
        private void create_listView(JSONObject friends, JSONObject caravans){
            JSONArray friend_array = new JSONArray();
            JSONArray caravans_array = new JSONArray();
            try{
                friend_array = friends.getJSONArray("user_ids");
                caravans_array = caravans.getJSONArray("user_ids");
            }catch(JSONException e){
                e.printStackTrace();
            }
            ArrayList<String[]> list_file = new ArrayList<String[]>();

            //friend_request structure = [time, "friend_request", username]
            //past caravan list structure = [time, "caravan", caravan_id, caravan destination, caravan members]
            for(int i = 0; i<friend_array.length(); i++){
                try {
                    list_file.add(new String[]{"0","friend_request",friend_array.getJSONObject(i).toString()});
                }catch(JSONException e){
                    e.printStackTrace();
                }
            }

//            for(int i = 0; i<caravans_array.length(); i++){
//                try {
//                    list_file.add(new String[]{"0","caravan",caravans_array.getJSONObject(i).toString()});
//                }catch(JSONException e){
//                    e.printStackTrace();
//                }
//            }

            home_list_adapter home_list_adapter= new home_list_adapter(list_file,homepage.this);
            list.setAdapter(home_list_adapter);

        }


    }
}
