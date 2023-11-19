uses graphWPF;

begin
  Window.Title := 'Змейка';
  window.SetSize(20 * 30 - 10, 20 * 30 - 10);
  Window.IsFixedSize := True; 
  var NewGame: boolean; 
  var q := new queue<integer>;//очередь для нажатых клавиш
  OnKeyDown := procedure (k: key) →
  lock q do //блокируем q от второго потока в теле программы
   case k of
    key.Left: q.Enqueue(1);
    Key.Right: q.Enqueue(2);
    Key.Up: q.Enqueue(8);
    Key.Down: q.Enqueue(9);
    Key.Escape: halt();
    Key.Enter: NewGame := true; //по нажатию Enter - новая игра
   end;
  repeat
    NewGame := false;
    Window.Clear;
    var (i, j) := (-1, 0); //координаты головы
    var n := 5; //длина змейки
    var p := 2; //направление следующего шага для головы
    var a := |(-1,0)|*n; //создаем массив индексов для звеньев змейки
    var (bi, bj) := Random2(2, 19); //координаты еды
    FillRectangle(bi * 30, bj * 30, 30, 30, Colors.DarkCyan); //вывод еды на экран
    repeat
      lock q do begin //блокируем q от второго потока OnKeyDown во избежание получения мусора 
        var newp := if q.Any then q.Dequeue else p; //перебираем очередь
        while q.Any and (abs(newp - p) < 2) do newp := q.Dequeue; //всё не нужное выбрасываем
        if abs(newp - p) > 2 then p := newp; //если новое направление "поворот", то записываем его в p
      end;
      case p of //меняем индекс для головы змейки в  торону p
        1: i -= 1; //влево
        2: i += 1;//вправо
        8: j -= 1;//вверх
        9: j += 1;//вниз
      end;
      if i = -1 then i := 19 else if i = 20 then i := 0; //перескок от стенки до стенки в другой конец экрана
      if j = -1 then j := 19 else if j = 20 then j := 0;
      if a.Contains((i, j)) and (a[n - 1] <> (i, j)) then //проверка на столкновение головы с телом змейки
      begin FillRectangle(i * 30, j * 30, 30, 30, Colors.Magenta); break; end;
      if (i = bi) and (j = bj) then //поели? удлиняем змейку на три клетки
      begin
        n += 3; 
        SetLength(a,n);
        for var f := 1 to 3 do a[n-f] := a[n - 4]; //массив змейки увеличить на 3 элемента
        (bi, bj) := Random2(0, 19); //новые координаты еды, которые..
        while a.Contains((bi, bj)) do (bi, bj) := Random2(0, 19); //..не совпадут с телом змейки
        FillRectangle(bi * 30, bj * 30, 30, 30, Colors.DarkCyan);//вывод еды на экран
      end;
      var pXBOCT: integer; //направление в котором нужно затирать клетку хвоста (след после хвоста)
      if abs(a[n - 2].Item1 - a[n - 3].Item1 + (a[n - 2].Item2 - a[n - 3].Item2) * 2 + 3) < 6 then//не перескчили в другой край экрана?
        pXBOCT := (a[n - 2].Item1 - a[n - 3].Item1 + (a[n - 2].Item2 - a[n - 3].Item2) * 2 + 3); 
      for var f := n - 1 downto 1 do a[f] := a[f - 1]; a[0] := (i, j); //каждая клетка змейки продвинулась на шаг впреред
      for var f := 0 to 29 do //вывод головы и затирание хвоста
      begin
        case p of //рисуем плавный шаг головы в новой клетке
          1: FillRectangle(29 - f + i * 30, j * 30, 1, 30, Colors.Red);
          2: FillRectangle(i * 30 + f, j * 30, 1, 30, Colors.Red);
          8: FillRectangle(i * 30, 29 - f + j * 30, 30, 1, Colors.Red);
          9: FillRectangle(i * 30, j * 30 + f, 30, 1, Colors.Red);
        end;
        case pXBOCT of //затираем плавно последнюю клетку хвоста
          4: FillRectangle(29 - f + a[n - 1].Item1 * 30, a[n - 1].Item2 * 30, 1, 30, Colors.White); //лево
          2: FillRectangle(a[n - 1].Item1 * 30 + f, a[n - 1].Item2 * 30, 1, 30, Colors.White); //право
          5: FillRectangle(a[n - 1].Item1 * 30, 29 - f + a[n - 1].Item2 * 30, 30, 1, Colors.White);//вверх
          1: FillRectangle(a[n - 1].Item1 * 30, a[n - 1].Item2 * 30 + f, 30, 1, Colors.White); //вниз
        end;      
        sleep(7);//скорость змейки
      end
    until NewGame;
    repeat sleep(100) until NewGame; //ждем нажатия Enter или Escape
  until false;
end.