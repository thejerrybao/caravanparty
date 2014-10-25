package com.example.selena_wang.frontend;

import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListAdapter;
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

/**
 * Created by selena_wang on 10/23/14.
 */
public class home_list_adapter extends BaseAdapter implements ListAdapter {

    // friend list structure = [time, "friend", username]
    //friend_request structure = [time, "friend_request", username]
    //past caravan list structure = [time, "caravan", caravan_id, caravan destination, caravan members]
    private ArrayList<String[]> list = new ArrayList<String[]>();
    private Context context;


    private LayoutInflater mInflater;

    public home_list_adapter(ArrayList<String[]> list, Context context) {
        this.list = list;
        this.context = context;
        mInflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    @Override
    public int getCount() {
        return list.size();
    }

    @Override
    public Object getItem(int pos) {
        return list.get(pos);
    }

    @Override
    public long getItemId(int pos) {
        return 0;
        //just return 0 if your list items do not have an Id variable.
    }

    private static final int friend_request = 0;
    private static final int caravan = 1;
    private static final int friend = 2;
    private static final int ERROR = 3;
    public int getItemViewType(String[] item){
        if(item[0]=="friend"){
            return friend_request;
        }else if(item[0]=="caravan"){
            return caravan;
        }else{
           return ERROR;
        }
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        ViewHolder holder = null;
        int type = getItemViewType(position);
        if (holder == null) {
            holder = new ViewHolder();
            switch(type) {
                case friend_request:
                    convertView = mInflater.inflate(R.layout.friend_request_item, null);

                    //Handle buttons and add onClickListeners
                    Button deleteBtn = (Button)convertView.findViewById(R.id.delete_btn);
                    Button addBtn = (Button)convertView.findViewById(R.id.add_btn);


                    holder.text1 = (TextView)convertView.findViewById(R.id.list_item_string);
                    holder.add = addBtn;
                    holder.delete= deleteBtn;
                    holder.text1.setText(list.get(position)[2] + " wants to be your friend!");

                    deleteBtn.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            list.remove(position);
                            notifyDataSetChanged();
                            //remove from database
                        }
                    });

                    addBtn.setOnClickListener(new View.OnClickListener(){
                        @Override
                        public void onClick(View v) {
                            new MyAsyncTask().execute("friend_request",Integer.toString(position));
                            list.remove(position);
                            notifyDataSetChanged();
                            //remove from database
                        }
                    });
                    break;
                case caravan:
                    convertView = mInflater.inflate(R.layout.past_caravan_item, null);
                    holder.text1 = (TextView)convertView.findViewById(R.id.list_item_destination);
                    holder.text2 = (TextView)convertView.findViewById(R.id.list_item_members);
                    holder.text1.setText(list.get(position)[2]);
                    holder.text2.setText("Members: " + list.get(position)[4]);
                    convertView.setOnClickListener(new OnItemClickListener(position));
                    break;
                case friend:
                    convertView = mInflater.inflate(R.layout.friend_item,null);
                    holder.text1 = (TextView)convertView.findViewById(R.id.friend_item_string);
                    holder.text1.setText(list.get(position)[2]);
                case ERROR:
                    throw new NullPointerException("Not Friend Request or Caravan");
            }
            convertView.setTag(holder);
        }
        return convertView;
    }

    public static class ViewHolder{

        public TextView text1;
        public TextView text2;
        public Button add;
        public Button delete;

    }

    private class OnItemClickListener  implements View.OnClickListener {
        private int mPosition;

        OnItemClickListener(int position){
            mPosition = position;
        }

        @Override
        public void onClick(View arg0) {
            String[] past_caravan_info = list.get(mPosition);
            Intent intent = new Intent(context,past_caravan.class);
            intent.putExtra("time",past_caravan_info[0]);
            intent.putExtra("caravan_id",Integer.valueOf(past_caravan_info[2]));
            intent.putExtra("caravan_destination",past_caravan_info[3]);
            intent.putExtra("caravan_members",past_caravan_info[4]);
            context.startActivity(intent);
        }
    }

    private class MyAsyncTask extends AsyncTask<String, Integer, Double> {
        private String username;
        private String password;

        @Override
        protected Double doInBackground(String... params) {
            if (params[0].equals("friend_request")) {
                friendRequest(params[0], Integer.valueOf(params[1]));
            }
            return null;
        }

        private void friendRequest(String parameter, int position) {
            HttpClient httpclient = new DefaultHttpClient();
            String extend_url = "users/" + homepage.get_user_id() + "/friend_request";
            HttpPost httppost = new HttpPost(homepage.url + extend_url);
            username = "placeholder";
            List data = new ArrayList();
            data.add(new BasicNameValuePair("user", username));
            try {
                httppost.setEntity(new UrlEncodedFormEntity(data));
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
            try {
                HttpResponse response = httpclient.execute(httppost);
                try {
                    JSONObject json = new JSONObject(EntityUtils.toString(response.getEntity()));

                } catch (JSONException e) {
                    e.printStackTrace();
                }

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}