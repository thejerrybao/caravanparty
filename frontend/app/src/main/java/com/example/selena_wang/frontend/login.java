package com.example.selena_wang.frontend;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.AsyncTask;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

public class login extends Activity {
    public static final String url = "http://salty-mountain-7480.herokuapp.com/";

    public static final int SUCCESS = 1;
    public static final int ERR_BAD_CREDENTIALS = -1;
    public static final int ERR_USER_EXISTS = -2;
    public static final int ERR_BAD_USERNAME = -3;
    public static final int ERR_BAD_PASSWORD = -4;
    public static final int MAX_USERNAME_LENGTH = 128;
    public static final int MAX_PASSWORD_LENGTH = 128;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login_layout);
        //getActionBar().setTitle("Login Counter");
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.login, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public void onClickLogin(View view){
        new MyAsyncTask().execute("login");
    }


    public void onClickCreate(View view){
        String username = ((EditText) findViewById(R.id.inputUser)).getText().toString();
        String password = ((EditText) findViewById(R.id.inputPass)).getText().toString();
        if(username.length()>MAX_USERNAME_LENGTH || username.length()==0) {
            createAlertDialog(ERR_BAD_USERNAME);
        }else if(password.length()>MAX_PASSWORD_LENGTH){
            createAlertDialog(ERR_BAD_PASSWORD);
        }else {
            new MyAsyncTask().execute("add");
        }
    }

    public void createAlertDialog(int ERR){
        String message = "";
        if(ERR==ERR_BAD_CREDENTIALS){
            message = "Invalid username and password combination. Please try again.";
        }else if(ERR==ERR_BAD_PASSWORD){
            message = "The password should be at most 128 characters long. Please try again.";
        }else if(ERR==ERR_BAD_USERNAME){
            message = "The user name should be non-empty and at most 128 characters long. Please try again.";
        }else if(ERR==ERR_USER_EXISTS){
            message = "This username already exists. Please try again.";
        }else{
            message = "Unknown Error";
        }
        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(login.this);
        alertDialogBuilder.setMessage(message);
        alertDialogBuilder.setNegativeButton("Okay",new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog,int id) {
                dialog.cancel();
            }
        });
        AlertDialog alertDialog = alertDialogBuilder.create();
        alertDialog.show();
    }

    private class MyAsyncTask extends AsyncTask<String, Integer, Double>{
        private String username;
        private String password;

        @Override
        protected Double doInBackground(String... params) {
            postData(params[0]);
            return null;
        }

        private void postData(String parameter) {
            HttpClient httpclient = new DefaultHttpClient();
            String extend_url = "";
            if(parameter.equals("add")){ extend_url = "users/add";}
            if(parameter.equals("login")){extend_url="users/login";}
            HttpPost httppost = new HttpPost(url + extend_url);
            username = ((EditText) findViewById(R.id.inputUser)).getText().toString();
            password = ((EditText) findViewById(R.id.inputPass)).getText().toString();
            List data= new ArrayList();
            data.add(new BasicNameValuePair("user", username));
            data.add(new BasicNameValuePair("password",password));
            try{
                httppost.setEntity(new UrlEncodedFormEntity(data));
            }catch(UnsupportedEncodingException e){
                e.printStackTrace();
            }
            try{
                HttpResponse response = httpclient.execute(httppost);
                try {
                    JSONObject json = new JSONObject(EntityUtils.toString(response.getEntity()));
                    try_log_add(json);

                }catch(JSONException e){
                    e.printStackTrace();
                }

            }catch (IOException e ) {
                e.printStackTrace();
            }
        }

        private void try_log_add(JSONObject json){
            final JSONObject json2 = json;
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    int ERR = 100;
                    int count = 100;
                    try {
                        ERR = json2.getInt("errCode");
                        count = json2.getInt("count");
                    }catch(JSONException e){
                        e.printStackTrace();
                    }
                    if(ERR==SUCCESS){
                        Intent intent = new Intent(login.this, homepage.class);
                        intent.putExtra("User", username);
                        intent.putExtra("Count", count);
                        startActivity(intent);
                    }else {
                        createAlertDialog(ERR);

                    }
                }
            });

        }
    }

}
