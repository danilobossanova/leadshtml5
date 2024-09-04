<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="UTF-8" isELIgnored ="false"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<html>
<head>
    <title>Lead - Formulario Site DCCO</title>

    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <!--script type="text/javascript" src="${BASE_FOLDER}/js/grafico.js"></!--script--> 

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${BASE_FOLDER}/css/estilo.css"> 

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>

    <snk:load/> <!-- essa tag deve ficar nesta posição -->    
</head>
<body>

    

    <snk:query var="leadsPorDepartamento">
        SELECT 
    CASE 
        WHEN TO_CHAR(DEPTO) = 'GE' THEN 'Geradores'
        WHEN TO_CHAR(DEPTO) = 'MA' THEN 'Maquinas'
        WHEN TO_CHAR(DEPTO) = 'PE' THEN 'Peças'
        WHEN TO_CHAR(DEPTO) = 'RE' THEN 'Locação'
        WHEN TO_CHAR(DEPTO) = 'SE' THEN 'Serviços'
        WHEN TO_CHAR(DEPTO) = 'SO' THEN 'Solar'
        ELSE 'Sem Depto Definido'
    END AS Departamento,
    
    COUNT(*) AS Total_Leads,
    COUNT(CASE WHEN STATUS = 'AB' THEN 1 END) AS Total_Abertos,
    COUNT(CASE WHEN STATUS = 'FE' THEN 1 END) AS Total_Fechados
FROM 
    AD_CRMGESINT
WHERE 
    ORIGEM = 'SI' 
    AND TIPINT = 'SO'
    AND TRUNC(DTCRIACAO) BETWEEN TRUNC(:PERIODO.INI) AND TRUNC(:PERIODO.FIN)
GROUP BY 
    CASE 
        WHEN TO_CHAR(DEPTO) = 'GE' THEN 'Geradores'
        WHEN TO_CHAR(DEPTO) = 'MA' THEN 'Maquinas'
        WHEN TO_CHAR(DEPTO) = 'PE' THEN 'Peças'
        WHEN TO_CHAR(DEPTO) = 'RE' THEN 'Locação'
        WHEN TO_CHAR(DEPTO) = 'SE' THEN 'Serviços'
        WHEN TO_CHAR(DEPTO) = 'SO' THEN 'Solar'
        ELSE 'Sem Depto Definido'
    END,
    TO_CHAR(TRUNC(DTCRIACAO, 'MM'), 'Month') -- Agrupamento por mês
ORDER BY 
    Departamento
    </snk:query>

    <snk:query var="totalLeadsPorPeriodo">
        SELECT 
        COUNT(*) AS Total_Leads,
        SUM(CASE WHEN STATUS = 'AB' THEN 1 ELSE 0 END) AS Total_Abertos,
        SUM(CASE WHEN STATUS = 'FE' THEN 1 ELSE 0 END) AS Total_Fechados,
        ROUND(AVG(CASE WHEN DTENCERRAMENTO IS NOT NULL THEN DTENCERRAMENTO - DTCRIACAO END)) AS Tempo_Medio_Encerramento_Dias,
        ROUND(AVG(CASE WHEN DTENCERRAMENTO IS NOT NULL AND DTENCERRAMENTO > DTCRIACAO + TEMPORET THEN DTENCERRAMENTO - (DTCRIACAO + TEMPORET) END)) AS Media_Dias_Atraso,
        SUM(CASE WHEN STATUS = 'AB' AND SYSDATE > DTCRIACAO + TEMPORET THEN 1 ELSE 0 END) AS Total_Abertos_Atrasados,
        ROUND(AVG(CASE WHEN STATUS = 'AB' AND SYSDATE > DTCRIACAO + TEMPORET THEN SYSDATE - (DTCRIACAO + TEMPORET) END)) AS Media_Dias_Atraso_Leads_Abertos
    FROM 
        AD_CRMGESINT
    WHERE 
        ORIGEM = 'SI' 
        AND TIPINT = 'SO'
        AND TRUNC(DTCRIACAO) BETWEEN TRUNC(:PERIODO.INI) AND TRUNC(:PERIODO.FIN)
    </snk:query>

    <div class="container-fluid">
        <c:forEach items="${totalLeadsPorPeriodo.rows}" var="rows">
            <div class="row">
                <div class="col-md-2">
                    <div class="card text-bg-secondary mb-3 " style="max-width: 18rem;">
                        <div class="card-header text-center">Total de Leads</div>
                        <div class="card-body">
                            <h3 class="card-title text-center"><c:out value="${row.Total_Leads}"/></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="card text-bg-secondary mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Abertos</div>
                        <div class="card-body">
                            <h3 class="card-title text-center"><c:out value="${row.Total_Abertos}"/></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="card text-bg-secondary mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Fechados</div>
                        <div class="card-body">
                            <h3 class="card-title text-center"><c:out value="${row.Total_Fechados}"/></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="card text-bg-dark mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Tempo Medio Resposta</div>
                        <div class="card-body">
                            <h3 class="card-title text-center"><c:out value="${row.Tempo_Medio_Encerramento_Dias}"/></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="card text-bg-dark mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Media Dias Atrasos - Fechados</div>
                        <div class="card-body">
                            <h3 class="card-title text-center"><c:out value="${row.Media_Dias_Atraso}"/></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="card text-bg-danger mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Abertos Atrasados</div>
                        <div class="card-body">
                            <h3 class="card-title text-center"><c:out value="${row.Total_Abertos_Atrasados}"/></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="card text-bg-danger mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Media Dias Atraso - Abertos</div>
                        <div class="card-body">
                            <h3 class="card-title text-center"><c:out value="${row.Media_Dias_Atraso_Leads_Abertos}" /></h3>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>

        <div class="row mt-4">
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">Cases Per Person</div>
                    <div class="card-body">
                        <div id="cases-per-person-chart"></div>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">Cases Per Filling Date</div>
                    <div class="card-body">
                        <div id="cases-per-filling-date-chart"></div>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">Leads por Dia</div> 
                    <div class="card-body">
                        <div id="leads-per-day-chart"></div> 
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">Leads por dia</div>
                    <div class="card-body">
                        <div id="chart_div"></div> 
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">Leads por Departamento</div>
                    <div class="card-body">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Departamento</th>
                                    <th>Total</th>
                                    <th>Abertos</th>
                                    <th>Fechados</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${leadsPorDepartamento.rows}" var="row"> 
                                    <tr>
                                        <td><c:out value="${row.Departamento}" /></td>
                                        <td><c:out value="${row.Total_Leads}" /></td>
                                        <td><c:out value="${row.Total_Abertos}" /></td>
                                        <td><c:out value="${row.Total_Fechados}" /></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        
    </div>

    
    
</body>
</html>