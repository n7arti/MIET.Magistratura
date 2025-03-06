package com.example.myapplication

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.core.tween
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.myapplication.ui.theme.MyApplicationTheme
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
                    Deduct()
                }
            }
        }
    }
}

@Composable
fun Deduct() {
    var isButtonClicked by remember { mutableStateOf(false) } // Состояние для отслеживания нажатия кнопки
    var screenHeight by remember { mutableStateOf(0.dp) } // Высота экрана
    val density = LocalDensity.current // Плотность пикселей для преобразования пикселей в dp

    // Анимация смещения текста вверх
    val textOffset by animateDpAsState(
        targetValue = if (isButtonClicked) (-screenHeight) else 0.dp,
        animationSpec = tween(durationMillis = 4000)
    )

    // Анимация прозрачности текста
    val textAlpha by animateFloatAsState(
        targetValue = if (isButtonClicked) 0f else 1f,
        animationSpec = tween(durationMillis = 4000)
    )

    // Сбрасываем состояние после завершения анимации
    LaunchedEffect(isButtonClicked) {
        if (isButtonClicked) {
            delay(4000) // Ждем завершения анимации (2 секунды)
            isButtonClicked = false // Сбрасываем состояние
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .onGloballyPositioned { coordinates ->
                // Получаем высоту экрана в пикселях и преобразуем в dp
                screenHeight = with(density) { coordinates.size.height.toDp() }
            }
    ) {
        // Кнопка (остается на месте)
        Button(
            onClick = { isButtonClicked = true }, // При нажатии включаем анимацию
            modifier = Modifier
                .padding(100.dp)
                .height(50.dp)
                .width(300.dp)
                .align(Alignment.BottomCenter)
        ) {
            Text("ОТЧИСЛИТЬСЯ")
        }

        // Текст, который появляется и улетает вверх
        if (isButtonClicked) {
            Text(
                text = "Поздравляю, вы отчислены!",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier
                    .padding(0.dp, 130.dp)
                    .align(Alignment.BottomCenter) // Начальная позиция текста (центр экрана)
                    .offset(y = textOffset) // Смещение текста вверх
                    .alpha(textAlpha) // Плавное исчезновение
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun PreviewDeduct() {
    MyApplicationTheme {
        Deduct()
    }
}