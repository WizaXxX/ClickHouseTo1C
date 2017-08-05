﻿
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	СтрокаВид = "Переменная";
	ДатаСостав = "ДатаВремя";
	
КонецПроцедуры

&НаКлиенте
Процедура ТипПриИзменении(Элемент)
	
	ТипСтрокой = ТипЗнч(Тип);
	ТипЗнч = ТипЗнч(Тип);
	
	УбратьВидимостьГрупп();
	
	Если ТипСтрокой = "Строка" Тогда
		Элементы.ГруппаСтрока.Видимость = Истина;
	ИначеЕсли ТипСтрокой = "Число" Тогда
		Элементы.ГруппаЧисло.Видимость = Истина;
	ИначеЕсли ТипСтрокой = "Дата" Тогда
		Элементы.ГруппаДата.Видимость = Истина;	
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура ТипНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
КонецПроцедуры


&НаКлиенте
Процедура УбратьВидимостьГрупп()
	Элементы.ГруппаСтрока.Видимость = Ложь;
	Элементы.ГруппаЧисло.Видимость = Ложь;
	Элементы.ГруппаДата.Видимость = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура Ок(Команда)
	
	Если ПустаяСтрока(Наименование) Тогда
		Сообщить("Введите наименование параметра");
		Возврат;
	КонецЕсли;
	
	КвалификаторСтроки = Новый КвалификаторыСтроки(СтрокаДлина, ДопустимаяДлина[СтрокаВид]);
	КвалификаторДаты = Новый КвалификаторыДаты(ЧастиДаты[ДатаСостав]);
	КвалификаторЧисла = Новый КвалификаторыЧисла(ЧислоДлина, ЧислоТочность, ?(ЧислоНеотрицательное, ДопустимыйЗнак.Неотрицательный, ДопустимыйЗнак.Любой));
	
	МассивТипов = Новый Массив;
	МассивТипов.Добавить(ТипЗнч);
	
	ОписаниеТипа = Новый ОписаниеТипов(МассивТипов, КвалификаторЧисла, КвалификаторСтроки, КвалификаторДаты);
	
	Структура = Новый Структура("Наименование, ОписаниеТипа, ДоступенСписок", Наименование, ОписаниеТипа, ДоступенСписокЗначений);
	
	Закрыть(Структура);
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	Закрыть();
КонецПроцедуры


