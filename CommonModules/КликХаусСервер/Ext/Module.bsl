﻿

Функция НастройкиСоединенияКорректны(АдресСервера = "", ПортСервера = "", Пользователь = "", Пароль = "", ЗащищенноеСоединение = Ложь, Таймаут = 0) Экспорт 
	
	НастройкиКорректны = Истина;
	
	АдресСервера = Константы.CH_АдресСервера.Получить();
	
	Если ПустаяСтрока(АдресСервера) Тогда
		Сообщить("Не заполнен адрес сервера ClickHouse");
		НастройкиКорректны = Ложь;		
	КонецЕсли;
	
	ПортСервера = Константы.CH_ПортСервера.Получить();
	
	Если Не ЗначениеЗаполнено(ПортСервера) Тогда
		Сообщить("Не заполнен порт сервера ClickHouse");
		НастройкиКорректны = Ложь;	
	КонецЕсли;
	
	Пользователь  = Константы.CH_Пользователь.Получить();
	Пароль = Константы.CH_ПарольПользователя.Получить();
	ЗащищенноеСоединение = Константы.CH_ЗащищенноеСоединение.Получить();
	Таймаут = Константы.CH_Таймаут.Получить();
	
	
	Возврат НастройкиКорректны;
	
КонецФункции

Функция СоединениеССерверомClickHouse() Экспорт
	
	АдресСервера = "";
	ПортСервера = 0;
	Пользователь = "";
	Пароль = "";
	ЗащищенноеСоединение = Ложь;
	Таймаут = 0;
	
	Если Не НастройкиСоединенияКорректны(АдресСервера, ПортСервера, Пользователь, Пароль, ЗащищенноеСоединение, Таймаут) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если ЗащищенноеСоединение Тогда
		ДанныеЗащищенноеСоединение = Новый ЗащищенноеСоединениеOpenSSL;
	Иначе
		ДанныеЗащищенноеСоединение = Неопределено;
	КонецЕсли;
	
	Соединение = Новый HTTPСоединение(АдресСервера, ПортСервера, Пользователь, Пароль,, Таймаут, ДанныеЗащищенноеСоединение);	
	                  
	Возврат Соединение;
	
КонецФункции

Функция ВыполнитьЗапросНаСервере(ТекстЗапроса, ИнформацияОВыполнении = Неопределено) Экспорт 
	
	Соединение = СоединениеССерверомClickHouse();
	
	Если Соединение = Неопределено Тогда
		Возврат "";
	КонецЕсли;
	
	ЗапросТекст = ТекстЗапроса + " FORMAT JSON";  
	
	ТекущаяДатаЗапросНачало = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	Запрос = Новый HTTPЗапрос("");          
	Запрос.УстановитьТелоИзСтроки(ЗапросТекст);
	
	Попытка
		Ответ = Соединение.ОтправитьДляОбработки(Запрос);
	Исключение
		Сообщить(ОписаниеОшибки());
		Возврат "";
	КонецПопытки;
	
	ТекущаяДатаЗапросКонец = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	ТекстОтвета = Ответ.ПолучитьТелоКакСтроку();
	
	Если Ответ.КодСостояния = 200 Тогда
		
		Чтение = Новый ЧтениеJSON;
		Чтение.УстановитьСтроку(ТекстОтвета);
		
		ИнформацияОВыполнении = ПрочитатьJSON(Чтение);
		
		Чтение.Закрыть();
		
	КонецЕсли;
	
	ТекущаяДатаЧтениеJSONКонец = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	Если Не ИнформацияОВыполнении = Неопределено Тогда
		ИнформацияОВыполнении.Вставить("ВремяВыполненияHTTPЗапроса", (ТекущаяДатаЗапросКонец - ТекущаяДатаЗапросНачало) / 1000);
		ИнформацияОВыполнении.Вставить("ВремяЧтенияJSON", (ТекущаяДатаЧтениеJSONКонец - ТекущаяДатаЗапросКонец) / 1000);
	КонецЕсли;
	
	Возврат "Код ответа: " + Ответ.КодСостояния + Символы.ПС + ТекстОтвета;
		
КонецФункции

Функция ПреобразоватьИнформациюОВыполненииВТабличныйДокумент(ИнформацияОВыполнении, РезультатВыполнения) Экспорт 
	
	ТабДок = Новый ТабличныйДокумент;
	Макет = Справочники.CH_Отчеты.ПолучитьМакет("МакетРезультат");
	
	ОбластьШапка = Макет.ПолучитьОбласть("ШапкаГор|Верт");
	ОбластьЗначение = Макет.ПолучитьОбласть("СтрокаГор|Верт");
	ОбластьОтступ = Макет.ПолучитьОбласть("СтрокаГор|СтрВерт");
	ОбластьОшибка = Макет.ПолучитьОбласть("ШапкаГор|ОшибкаВерт");
	
	ТабДок.Вывести(ОбластьОтступ);
	
	Если ИнформацияОВыполнении = Неопределено Тогда
		ОбластьОшибка.Параметры.РезультатВыполнения = РезультатВыполнения;
		ТабДок.Присоединить(ОбластьОшибка);
		
		Возврат ТабДок;
		
	КонецЕсли;
	
	
	Для Каждого СтрокаСтруктуры Из ИнформацияОВыполнении.meta Цикл
		
		ОбластьШапка.Параметры.Заполнить(СтрокаСтруктуры);
		ТабДок.Присоединить(ОбластьШапка);
 
	КонецЦикла;
	
	
	Для Каждого СтрокаДанных Из ИнформацияОВыполнении.data Цикл
		ТабДок.Вывести(ОбластьОтступ);
		
		Для Каждого СтрокаСтруктуры Из ИнформацияОВыполнении.meta Цикл
			ОбластьЗначение.Параметры.ЗначениеДанных =  СтрокаДанных[СтрокаСтруктуры.name];
			ТабДок.Присоединить(ОбластьЗначение);
		КонецЦикла;
		
		
	КонецЦикла;
	
	Возврат ТабДок;
	
КонецФункции

Функция ПреобразоватьИнформациюОВыполненииВТаблицуЗначений(ИнформацияОВыполнении, СхемаКомпоновкиДанных) Экспорт
	
	МассивСсылочныхТипов = Новый Массив;
	
	ТаблицаЗначений = Новый ТаблицаЗначений;
	
	Для Каждого СтрокаПоля Из СхемаКомпоновкиДанных.НаборыДанных.ВнешДанные.Поля Цикл
		ТаблицаЗначений.Колонки.Добавить(СтрокаПоля.Поле, СтрокаПоля.ТипЗначения); 
	КонецЦикла;
	
	ТаблицаЗначений.Добавить();
	 
	Для Каждого Колонка Из ТаблицаЗначений.Колонки Цикл
		Тип = XMLТипЗнч(ТаблицаЗначений[0][Колонка.Имя]);
		
		Если СтрНайти(Тип.ИмяТипа, "Ref.") = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Структура = Новый Структура;
		Структура.Вставить("Тип", ТипЗнч(ТаблицаЗначений[0][Колонка.имя]));
		Структура.Вставить("Имя", Колонка.Имя);
		
		МассивСсылочныхТипов.Добавить(Структура);
		
	КонецЦикла;
	
	ТаблицаЗначений.Удалить(0);
	
	Для Каждого СтрокаДанных Из ИнформацияОВыполнении.data Цикл
		
		НоваяСтрока = ТаблицаЗначений.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаДанных);
		
		Для Каждого СсылочныйТип Из МассивСсылочныхТипов Цикл
			НоваяСтрока[СсылочныйТип.Имя] = XMLЗначение(СсылочныйТип.Тип, СтрокаДанных[СсылочныйТип.Имя]); 		
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ТаблицаЗначений;
	
КонецФункции

Функция ИнициализироватьСКД(Отчет_CH) Экспорт
	
	СХ = Отчеты.ШаблонОтчета.ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанных");
	
	СхемаКомпоновкиДанных = Новый СхемаКомпоновкиДанных;
	
	НовыйНаборДанных = СхемаКомпоновкиДанных.НаборыДанных.Добавить(Тип("НаборДанныхОбъектСхемыКомпоновкиДанных"));
	
	НовыйНаборДанных.Имя = "ВнешДанные";
	НовыйНаборДанных.ИмяОбъекта = "ВнешДанные";
	НовыйНаборДанных.ИсточникДанных = "ОсновнойИсточникДанных";
	
	Параметр = СхемаКомпоновкиДанных.Параметры.Добавить();
	Параметр.ВключатьВДоступныеПоля = Ложь;
	Параметр.Заголовок = "Отчет CH";
	Параметр.ЗапрещатьНезаполненныеЗначения = Истина;
	Параметр.Имя = "Отчет_CH";
	Параметр.Использование = ИспользованиеПараметраКомпоновкиДанных.Всегда;
	Параметр.ОграничениеИспользования = Истина;
	Параметр.ТипЗначения = Новый ОписаниеТипов("СправочникСсылка.CH_Отчеты");
	Параметр.Значение = Отчет_CH;
	
	
	Возврат СхемаКомпоновкиДанных;
	
КонецФункции

Функция АктуализироватьСКД(СхемаКомпоновкиДанных, Отчет_CH) Экспорт 
	
	ПоляКомпоновки = СхемаКомпоновкиДанных.НаборыДанных.ВнешДанные.Поля;
	
	Для Каждого Поле Из Отчет_CH.ПоляЗапроса Цикл
		
		Если Не ПоляКомпоновки.Найти(Поле.Наименование) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		НовоеПоле = ПоляКомпоновки.Добавить(Тип("ПолеНабораДанныхСхемыКомпоновкиДанных"));
		НовоеПоле.Поле = Поле.Наименование;
		НовоеПоле.ПутьКДанным = Поле.Наименование;
		
		МассивТипов = Новый Массив;
		МассивТипов.Добавить(ТипЗнч(Поле.Тип));
		
		НовоеПоле.ТипЗначения = Новый ОписаниеТипов(МассивТипов); 
		
	КонецЦикла;
	
КонецФункции

Процедура НачатьФормированиеОтчета(ОтчетСсылка, АдресРезультат, НастройкиФормирования) Экспорт
	
	Попытка
		Результат = СформироватьОтчет(ОтчетСсылка, НастройкиФормирования);		
	Исключение
		ПоместитьВоВременноеХранилище(ОписаниеОшибки(), АдресРезультат);
		Возврат;
	КонецПопытки;
		
	ПоместитьВоВременноеХранилище(Результат, АдресРезультат);
	
КонецПроцедуры

Функция СформироватьОтчет(ОтчетСсылка, НастройкиКомпоновки)
	
	ДокументРезультат = Новый ТабличныйДокумент;
	
	СхемаКомпоновкиДанных = ОтчетСсылка.СхемаКомпоновкиДанных.Получить();
	
	ИнформацияОВыполнении = Неопределено;
	
	ТекстЗапроса = ЗаполнитьПараметрыДанных(ОтчетСсылка.ТекстЗапроса, НастройкиКомпоновки, СхемаКомпоновкиДанных);
	
	Результат = КликХаусСервер.ВыполнитьЗапросНаСервере(ТекстЗапроса, ИнформацияОВыполнении);
	
	Если ИнформацияОВыполнении = Неопределено Тогда
		Возврат "Не удалось получить данные от ClickHouse" + Символы.ПС + Результат;
	КонецЕсли;
	
	ВнешДанные = КликХаусСервер.ПреобразоватьИнформациюОВыполненииВТаблицуЗначений(ИнформацияОВыполнении, СхемаКомпоновкиДанных);	
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновкиДанных = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиКомпоновки);
	
	СтруктураДанных = Новый Структура("ВнешДанные", ВнешДанные);
	
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновкиДанных, СтруктураДанных,, Истина);
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных, Истина);
	
	Возврат ДокументРезультат;
	
КонецФункции

Функция ЗаполнитьПараметрыДанных(Знач ТекстЗапросаОтчет, НастройкиКомпоновки, СхемаКомпоновкиДанных)
	
	ТекстЗапроса = ТекстЗапросаОтчет;
	
	Для Каждого ДанныеПараметра Из НастройкиКомпоновки.ПараметрыДанных.Элементы Цикл
		
		ЗначениеПараметра = "";
		
		ТипСКД = СхемаКомпоновкиДанных.Параметры[Строка(ДанныеПараметра.Параметр)].ТипЗначения;
		
		Если ТипЗнч(ДанныеПараметра.Значение) = Тип("СписокЗначений") Тогда
			ЗначениеПараметра = ПолучитьСписокЗначений(ДанныеПараметра.Значение, ТипСКД);
		Иначе
			ЗначениеПараметра = ПолучитьЗначение(ДанныеПараметра.Значение, ТипСКД);
		КонецЕсли;
		
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&" + ДанныеПараметра.Параметр, ЗначениеПараметра);
		
	КонецЦикла;
	
	Возврат ТекстЗапроса;
	
КонецФункции

Функция ПолучитьСписокЗначений(ИскомоеЗначение, ТипСКД)
	
	СтрокаЗначения = "";
	
	Для Каждого ЭлементЗначения Из ИскомоеЗначение Цикл
		СтрокаЗначения = СтрокаЗначения + ПолучитьЗначение(ЭлементЗначения.Значение, ТипСКД) + ",";
	КонецЦикла;
	
	СтрокаЗначения = Сред(СтрокаЗначения, 1, СтрДлина(СтрокаЗначения) - 1);
	
	Возврат "(" + СтрокаЗначения + ")";
	
КонецФункции

Функция ПолучитьЗначение(ИскомоеЗначение, ТипСКД)
	
	Если ТипЗнч(ИскомоеЗначение) = Тип("Число") Тогда
		Возврат Формат(ИскомоеЗначение, "ЧРГ=.");
		
	ИначеЕсли ТипЗнч(ИскомоеЗначение) = Тип("Булево") Тогда
		Возврат Формат(ИскомоеЗначение, "БЛ=0; БИ=1");
		
	ИначеЕсли ТипЗнч(ИскомоеЗначение) = Тип("Строка") Тогда
		Возврат "'" + ИскомоеЗначение + "'";
		
	ИначеЕсли ТипЗнч(ИскомоеЗначение) = Тип("СтандартнаяДатаНачала") Тогда 		
		Возврат "'" + ВернутьЗначениеПараметраДата(ИскомоеЗначение.Дата, ТипСКД) + "'";
		
	ИначеЕсли ТипЗнч(ИскомоеЗначение) = Тип("Дата") Тогда
		Возврат "'" + ВернутьЗначениеПараметраДата(ИскомоеЗначение, ТипСКД) + "'";
		
	Иначе
		Возврат "'" + ИскомоеЗначение.УникальныйИдентификатор() + "'";
		
	КонецЕсли;
	
КонецФункции

Функция ВернутьЗначениеПараметраДата(Дата, ТипСКД)
	
	Если ТипСКД.КвалификаторыДаты.ЧастиДаты = ЧастиДаты.Дата Тогда
		Возврат Формат(Дата, "ДФ=yyyy-MM-dd");
	ИначеЕсли ТипСКД.КвалификаторыДаты.ЧастиДаты = ЧастиДаты.ДатаВремя Тогда
		Возврат Формат(Дата, "ДФ=yyyy-MM-dd-HH-mm-ss");
	Иначе
		Возврат Формат(Дата, "ДФ=1970-01-02-HH-mm-ss");
	КонецЕсли;
	
КонецФункции


