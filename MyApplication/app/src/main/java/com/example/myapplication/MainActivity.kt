package com.example.myapplication

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.Button
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.myapplication.ui.theme.MyApplicationTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    PlusOne(
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}

@Composable
fun PlusOne(modifier: Modifier = Modifier) {
    // Создаем состояние с помощью remember и mutableStateOf
    var count by remember { mutableStateOf(0) }

    Box(
        modifier = Modifier
            .fillMaxSize()
    ) {
        // Отображаем текущее значение счетчика
        Text(
            text = "$count",
            modifier = Modifier
                .align(Alignment.Center)
                .offset(y = (-100).dp)
        )

        // Кнопка "+"
        Button(
            onClick = { count++ },
            modifier = Modifier
                .align(Alignment.Center)
                .offset(x = 100.dp)
        ) {
            Text("плАчу")
        }

        // Кнопка "-"
        Button(
            onClick = { count-- },
            modifier = Modifier
                .align(Alignment.Center)
                .offset(x = (-100).dp)
        ) {
            Text("плачУ")
        }
    }
}

@Preview(showBackground = true)
@Composable
fun PlusOnePreview() {
    MyApplicationTheme {
        PlusOne()
    }
}