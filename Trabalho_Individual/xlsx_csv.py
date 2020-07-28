import xlrd
import csv
import pandas

def csv_from_excel():
    wb = xlrd.open_workbook('adjacencias.xlsx')
    sheets = wb.sheet_names()

    for sheet in range(0,len(sheets)):
       ficheiro = "Adjacencias/adjacencia" + sheets[sheet] +".csv"

       read = pandas.read_excel('adjacencias.xlsx',sheet_name = sheets[sheet])
       read.to_csv(ficheiro,index=None,header=True)


csv_from_excel()