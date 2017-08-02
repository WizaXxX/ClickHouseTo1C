﻿
&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	СКД = ТекущийОбъект.СхемаКомпоновкиДанных.Получить();
	
	Если СКД = Неопределено Тогда	
		СКД = КликХаусСервер.ИнициализироватьСКД(ТекущийОбъект.Ссылка);
		Сообщить("Инициализирована Схема компоновки данных");
		Модифицированность = Истина;
	КонецЕсли;
	
	СхемаКомпоновкиДанных = ПоместитьВоВременноеХранилище(СКД, УникальныйИдентификатор);
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если СхемаКомпоновкиДанных = "" Тогда
		СКД = Неопределено;
	Иначе
		СКД = ПолучитьИзВременногоХранилища(СхемаКомпоновкиДанных);
	КонецЕсли;
	
	ТекущийОбъект.СхемаКомпоновкиДанных = Новый ХранилищеЗначения(СКД);
	
КонецПроцедуры

&НаСервере
Функция ПолучитьМассивПараметровЗапроса()
	
	Возврат Объект.ПараметрыЗапроса.Выгрузить().ВыгрузитьКолонку("Наименование");
	
КонецФункции

&НаКлиенте
Процедура КонсольЗапроса(Команда)
		
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьЗакрытиеФормыКонсоли", ЭтотОбъект);
	
	ПараметрыНовойФормы = Новый Структура("ТекстЗапроса, ПараметрыЗапроса", Объект.ТекстЗапроса, ПолучитьМассивПараметровЗапроса());
	
	ОткрытьФорму("Справочник.CH_Отчеты.Форма.КонсольЗапроса", ПараметрыНовойФормы, ЭтаФорма,,ВариантОткрытияОкна.ОтдельноеОкно,,ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьЗакрытиеФормыКонсоли(Результат, ДопПараметры) Экспорт 
	
	Если Не Результат = Неопределено Тогда
		Модифицированность = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТекстЗапросаПриИзменении(Элемент)
	
	//Позиция = СтрНайти(Объект.ТекстЗапроса, "&",, 1);
	//
	//Пока Не Позиция = 0 Цикл
	//	
	////TODO:  сделать парсинг параметров запроса		
	//	
	//КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура КонструкторСхемыКомпоновкиДанных(Команда)
	
	Если Модифицированность 
		Или Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Сообщить("Перед модицикацией СКД, запишите отчет.");
		
		Возврат;
		
	КонецЕсли;
	
	#Если ТолстыйКлиентУправляемоеПриложение Тогда
		Если Не ЗначениеЗаполнено(СхемаКомпоновкиДанных) Тогда
			СКД = КликХаусСервер.ИнициализироватьСКД(Объект.Ссылка);
			СхемаКомпоновкиДанных = ПоместитьВоВременноеХранилище(СКД, УникальныйИдентификатор);	
		КонецЕсли;
		
		СКД = ПолучитьИзВременногоХранилища(СхемаКомпоновкиДанных);
		
		КликХаусСервер.АктуализироватьСКД(СКД, Объект.Ссылка);
		
		КонструкторСКД = Новый КонструкторСхемыКомпоновкиДанных(СКД);
		КонструкторСКД.Редактировать(ЭтаФорма);
		
	#Иначе
		Сообщить("Модификация СКД может производиться только в толстом клиенте (упр).");
	#КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Модифицированность = Истина;
	ПоместитьВоВременноеХранилище(ВыбранноеЗначение, СхемаКомпоновкиДанных);
	
КонецПроцедуры








