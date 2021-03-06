﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не Параметры.Свойство("ОтчетСсылка", ОтчетСсылка) Тогда
		Отказ = Истина;
	КонецЕсли;
		
	Заголовок = "Отчет CH: " + ОтчетСсылка;
	
	СхемаКомпоновкиДанных = ОтчетСсылка.СхемаКомпоновкиДанных.Получить();
	
	Попытка
		АдресСКД = ПоместитьВоВременноеХранилище(СхемаКомпоновкиДанных, УникальныйИдентификатор);
		
		ИсточникНастроек = Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресСКД);
		
		КомпоновщикНастроек.Инициализировать(ИсточникНастроек);
		КомпоновщикНастроек.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	Исключение
		Отказ = Истина;	
		Сообщить("Отчет: " + ОтчетСсылка + " не настроен.");	
	КонецПопытки;
		
КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда)
		
	СформироватьНаСервере();
	
	ПодключитьОбработчикОжидания("ПроверитьФормированиеОтчета", 2);
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьФормированиеОтчета() Экспорт 
	
	Данные = ПолучитьИзВременногоХранилища(АдресРезультат);
	
	Если Данные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОтключитьОбработчикОжидания("ПроверитьФормированиеОтчета");
	
	
	Если ТипЗнч(Данные) = Тип("Строка") Тогда
		Сообщить(Данные);
	Иначе 
		Результат = Данные;
	КонецЕсли;
	
	Элементы.КольцоПрогресса.Видимость = Ложь;
	Элементы.Результат.Видимость = Истина;	
		
КонецПроцедуры

&НаСервере
Процедура СформироватьНаСервере()
	
	Элементы.КольцоПрогресса.Видимость = Истина;
	Элементы.Результат.Видимость = Ложь;
	
	АдресРезультат = ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор);
		
	МассивПараметров = Новый Массив;
	МассивПараметров.Добавить(ОтчетСсылка);
	МассивПараметров.Добавить(АдресРезультат);
	МассивПараметров.Добавить(КомпоновщикНастроек.ПолучитьНастройки());
	
	Наименование = "Формирование отчета: " + ОтчетСсылка;
	
	ФоновыеЗадания.Выполнить("КликХаусСервер.НачатьФормированиеОтчета", МассивПараметров, ОтчетСсылка.УникальныйИдентификатор(), Наименование);
	
КонецПроцедуры



