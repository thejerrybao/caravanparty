package com.example.selena_wang.frontend;

import android.app.Activity;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
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


public class findfriends extends Fragment {

    private String current_search_id;
    private  String current_search_name;
    private Button search_button;
    private Button add_button;

    public void onClickSearch(View view){
        new MyAsyncTask().execute("search");
    }

    public void onClickAdd(View view){
        new MyAsyncTask().execute("add");
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.findfriends_layout, container, false);
        search_button = (Button)view.findViewById(R.id.search_button);
        add_button = (Button)view.findViewById(R.id.addButton);
        return view;
    }


    private class MyAsyncTask extends AsyncTask<String, Integer, Double> {
        private String username;

        @Override
        protected Double doInBackground(String... params) {
            if(params[0].equals("search")){
                searchUser(params[0]);
            }else if(params[0].equals("add")){
                addUser(params[0]);
            }
            return null;
        }

        private void searchUser(String parameter){
            HttpClient httpclient = new DefaultHttpClient();
            username = ((EditText)getView().findViewById(R.id.inputFriend)).getText().toString();
            String friend_url = "users/" + username;
            HttpPost httpPost_friend = new HttpPost(homepage.url + friend_url);
            List data= new ArrayList();
            try{
                httpPost_friend.setEntity(new UrlEncodedFormEntity(data));

            }catch (UnsupportedEncodingException e){
                e.printStackTrace();
            }
            try{
                HttpResponse response_user = httpclient.execute(httpPost_friend);
                try{
                    JSONObject json_user = new JSONObject(EntityUtils.toString(response_user.getEntity()));
                    current_search_id = json_user.getString("user_id");
                    current_search_name = json_user.getString("username");
                    TextView user_text = ((TextView)getView().findViewById(R.id.friend_info));
                    user_text.setText("The id " + current_search_id + " is associated with " + current_search_name + ".");
                    add_button.setVisibility(View.VISIBLE);

                }catch(JSONException e){
                    e.printStackTrace();
                }
            }catch (IOException e){
                e.printStackTrace();
            }


        }

        // list structure = [caravan/friend, username/caravan_id, caravan destination, caravan members]
        private void addUser(String parameter){
            HttpClient httpclient = new DefaultHttpClient();
            username = ((EditText)getView().findViewById(R.id.inputFriend)).getText().toString();
            String to_add_url = "users/" + homepage.get_user_id() + "/friends/add/" + current_search_id;
            HttpPost httpPost_friend = new HttpPost(homepage.url + to_add_url);
            List data= new ArrayList();
            try{
                httpPost_friend.setEntity(new UrlEncodedFormEntity(data));

            }catch (UnsupportedEncodingException e){
                e.printStackTrace();
            }
            try{
                HttpResponse response_user = httpclient.execute(httpPost_friend);
                try{
                    JSONObject json_user = new JSONObject(EntityUtils.toString(response_user.getEntity()));
                    if(json_user.getInt("reply_code")==homepage.SUCCESS) {
                        TextView user_text = ((TextView) getView().findViewById(R.id.friend_info));
                        user_text.setText("");
                        add_button.setVisibility(View.INVISIBLE);
                    }

                }catch(JSONException e){
                    e.printStackTrace();
                }
            }catch (IOException e){
                e.printStackTrace();
            }

        }


    }
}
