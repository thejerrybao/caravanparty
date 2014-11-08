package com.example.selena_wang.frontend;

import android.app.ActionBar;
import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.Layout;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ListView;
import android.widget.RelativeLayout;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;


public class friends extends Activity {

    private static boolean active = false;

    public static boolean getActive(){
        return active;
    }

    ListView friendList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.friends_layout);
        createListView();
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
        inflater.inflate(R.menu.action_bar, menu);

        ActionBar bar = getActionBar();
        bar.setHomeButtonEnabled(true);
        bar.setDisplayShowHomeEnabled(true);

        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if(id==android.R.id.home){
            Intent intent = new Intent(this,homepage.class);
            if(homepage.getActive()){
                intent.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            }
            startActivity(intent);
        }
        else if (id == R.id.friend_icon) {
            FragmentManager manager = getFragmentManager();
            Fragment find_friends_fragment = manager.findFragmentById(R.id.findFriendsFragment);
            int width = find_friends_fragment.getView().getWidth();
            if(width!=0){
                RelativeLayout main_layout = (RelativeLayout) findViewById(R.id.friends_main);
                main_layout.setVisibility(View.VISIBLE);
                ViewGroup.LayoutParams layout = find_friends_fragment.getView().getLayoutParams();
                layout.width = 0;
                find_friends_fragment.getView().setLayoutParams(layout);
            }
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

    public void onClickFindFriends(View view){
        RelativeLayout main_layout = (RelativeLayout) findViewById(R.id.friends_main);
        main_layout.setVisibility(View.INVISIBLE);
        FragmentManager manager = getFragmentManager();
        Fragment find_friends_fragment = manager.findFragmentById(R.id.findFriendsFragment);
        ViewGroup.LayoutParams layout = find_friends_fragment.getView().getLayoutParams();
        layout.width = RelativeLayout.LayoutParams.MATCH_PARENT;
        find_friends_fragment.getView().setLayoutParams(layout);
    }


    private class MyAsyncTask extends AsyncTask<String, Integer, Double> {

        @Override
        protected Double doInBackground(String... params) {
            if(params[0].equals("list")){
                createList(params[0]);
            }
            return null;
        }

        private void createList(String parameter){
            String friend_url = "users/" + homepage.get_user_id() + "/friends";
            HttpClient httpclient = new DefaultHttpClient();
            HttpPost httpPost_friend = new HttpPost(homepage.url + friend_url);
            List data1 = new ArrayList();
            try{
                httpPost_friend.setEntity(new UrlEncodedFormEntity(data1));

            }catch (UnsupportedEncodingException e){
                e.printStackTrace();
            }
            try{
                HttpResponse response_friend = httpclient.execute(httpPost_friend);
                try{
                    JSONObject json_friend = new JSONObject(EntityUtils.toString(response_friend.getEntity()));
                    create_listView(json_friend);
                }catch(JSONException e){
                    e.printStackTrace();
                }
            }catch (IOException e){
                e.printStackTrace();
            }


        }

        // list structure = [caravan/friend, username/caravan_id, caravan destination, caravan members]
        private void create_listView(JSONObject friends){
            JSONArray friend_array = new JSONArray();
            try{
                friend_array = friends.getJSONArray("user_ids");
            }catch(JSONException e){
                e.printStackTrace();
            }

            List<String> user_ids = new ArrayList<String>();
            for(int i = 0; i<friend_array.length(); i++){
                try {
                    user_ids.add(friend_array.getJSONObject(i).toString());
                }catch(JSONException e){
                    e.printStackTrace();
                }
            }

            ArrayList<String[]> list_file = new ArrayList<String[]>();
            for(int i = 0;i<user_ids.size(); i++){
                String[] to_add = {"time","friend",user_ids.get(i)};
                list_file.add(to_add);
            }
            home_list_adapter friend_list_adapter= new home_list_adapter(list_file,friends.this);
            friendList.setAdapter(friend_list_adapter);

        }


    }
}
