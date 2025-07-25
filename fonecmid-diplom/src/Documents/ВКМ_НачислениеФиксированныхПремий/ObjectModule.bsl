
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий 

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	СформироватьДвижения();
	РассчитатьУдержания();
	СформироватьДвиженияВКМ_ВзаиморасчетыССотрудниками();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции 

Процедура СформироватьДвижения()
	
	Для Каждого Строка Из СписокСотрудников Цикл
		
		Движение = Движения.ВКМ_ДополнительныеНачисления.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_ДополнительныеНачисления.ФиксПремия;
		Движение.Сотрудник = Строка.Сотрудник;
		Движение.Результат = Строка.СуммаПремии;
		
		Движение = Движения.ВКМ_Удержания.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
		Движение.Сотрудник = Строка.Сотрудник;
		Движение.БазовыйПериодНачало = НачалоМесяца(Дата);
		Движение.БазовыйПериодКонец = КонецМесяца(Дата);
		
	КонецЦикла;
	
	Движения.ВКМ_ДополнительныеНачисления.Записать();
	Движения.ВКМ_Удержания.Записать();
	
КонецПроцедуры

Процедура РассчитатьУдержания()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВКМ_Удержания.НомерСтроки КАК НомерСтроки,
	|	ВКМ_УдержанияБазаВКМ_ДополнительныеНачисления.Сотрудник КАК Сотрудник,
	|	ЕСТЬNULL(ВКМ_УдержанияБазаВКМ_ДополнительныеНачисления.РезультатБаза, 0) КАК База
	|ПОМЕСТИТЬ ВТ_ВсеДопНачисленияБаза
	|ИЗ
	|	РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания.БазаВКМ_ДополнительныеНачисления(&Измерения, &Измерения, , Регистратор = &Ссылка) КАК ВКМ_УдержанияБазаВКМ_ДополнительныеНачисления
	|		ПО ВКМ_Удержания.НомерСтроки = ВКМ_УдержанияБазаВКМ_ДополнительныеНачисления.НомерСтроки
	|ГДЕ
	|	ВКМ_Удержания.Регистратор = &Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВКМ_ДополнительныеНачисления.Сотрудник КАК Сотрудник,
	|	ЕСТЬNULL(ВКМ_ДополнительныеНачисления.Результат, 0) КАК Результат
	|ПОМЕСТИТЬ ВТ_Надбавки
	|ИЗ
	|	РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
	|ГДЕ
	|	ВКМ_ДополнительныеНачисления.ПериодРегистрации = &ПериодРегистрации
	|	И ВКМ_ДополнительныеНачисления.Регистратор <> &Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ВсеДопНачисленияБаза.НомерСтроки КАК НомерСтроки,
	|	ВТ_ВсеДопНачисленияБаза.Сотрудник КАК Сотрудник,
	|	ЕСТЬNULL(ВТ_ВсеДопНачисленияБаза.База, 0) - ЕСТЬNULL(ВТ_Надбавки.Результат, 0) КАК Результат
	|ИЗ
	|	ВТ_ВсеДопНачисленияБаза КАК ВТ_ВсеДопНачисленияБаза
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Надбавки КАК ВТ_Надбавки
	|		ПО ВТ_ВсеДопНачисленияБаза.Сотрудник = ВТ_Надбавки.Сотрудник";
	
	Измерения = Новый Массив;
	Измерения.Добавить("Сотрудник");
	Запрос.УстановитьПараметр("Измерения", Измерения);
	
	Запрос.УстановитьПараметр("ПериодРегистрации", НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Движение = Движения.ВКМ_Удержания[Выборка.НомерСтроки - 1];
		Движение.Результат = Выборка.Результат * 0.13;
		
	КонецЦикла;
	
	Движения.ВКМ_Удержания.Записать( , Истина);
	
КонецПроцедуры

Процедура СформироватьДвиженияВКМ_ВзаиморасчетыССотрудниками()
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВКМ_ДополнительныеНачисления.Сотрудник КАК Сотрудник,
	|	СУММА(ВКМ_ДополнительныеНачисления.Результат) КАК Результат
	|ПОМЕСТИТЬ ВТ_ДопНачисления
	|ИЗ
	|	РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
	|ГДЕ
	|	ВКМ_ДополнительныеНачисления.Регистратор = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	ВКМ_ДополнительныеНачисления.Сотрудник
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВКМ_Удержания.Сотрудник КАК Сотрудник,
	|	СУММА(ВКМ_Удержания.Результат) КАК Результат
	|ПОМЕСТИТЬ ВТ_Удержания
	|ИЗ
	|	РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
	|ГДЕ
	|	ВКМ_Удержания.Регистратор = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	ВКМ_Удержания.Сотрудник
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДопНачисления.Сотрудник КАК Сотрудник,
	|	ЕСТЬNULL(ВТ_ДопНачисления.Результат, 0) КАК ДопНач,
	|	ЕСТЬNULL(ВТ_Удержания.Результат, 0) КАК Удержания
	|ИЗ
	|	ВТ_ДопНачисления КАК ВТ_ДопНачисления
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Удержания КАК ВТ_Удержания
	|		ПО ВТ_ДопНачисления.Сотрудник = ВТ_Удержания.Сотрудник";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.ДобавитьПриход();
		Движение.Период = Дата;
		Движение.Сотрудник = Выборка.Сотрудник;
		Движение.Сумма = Выборка.ДопНач - Выборка.Удержания;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Иначе
  	ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли
