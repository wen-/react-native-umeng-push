package com.liuchungui.react_native_umeng_push;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * Created by user on 16/4/7.
 */
public class UmengPushPackage implements ReactPackage {
    public UmengPushModule uPushModule;

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        uPushModule = new UmengPushModule(reactContext);
        return Arrays.asList(new NativeModule[]{
                // Modules from third-party
                uPushModule,
        });
    }

    public List<Class<? extends JavaScriptModule>> createJSModules() {
        return Collections.emptyList();
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }
}
