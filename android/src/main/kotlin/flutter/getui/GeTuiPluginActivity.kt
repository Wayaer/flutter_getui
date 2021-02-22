package flutter.getui

import android.app.Activity
import android.os.Bundle
import com.igexin.sdk.GTServiceManager

class GeTuiPluginActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle) {
        super.onCreate(savedInstanceState)
        GTServiceManager.getInstance().onActivityCreate(this)
    }
}