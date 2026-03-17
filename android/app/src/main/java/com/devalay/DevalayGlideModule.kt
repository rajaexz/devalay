package com.devalay

import android.content.Context
import com.bumptech.glide.GlideBuilder
import com.bumptech.glide.annotation.GlideModule
import com.bumptech.glide.module.AppGlideModule

@GlideModule
class DevalayGlideModule : AppGlideModule() {
    override fun applyOptions(context: Context, builder: GlideBuilder) {
        // Keep default options for now; customize here if the app needs tweaks.
        super.applyOptions(context, builder)
    }

    override fun isManifestParsingEnabled(): Boolean = false
}

