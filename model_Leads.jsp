<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="UTF-8" isELIgnored ="false"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<html>
<head>
    <title>Lead - Formulario Site DCCO</title>

    <!--script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></!--script-->
    <!--script type="text/javascript" src="${BASE_FOLDER}/js/grafico.js"></!--script--> 

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="${BASE_FOLDER}/css/estilo.css"> 

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>
    <script src="https://code.highcharts.com/highcharts.js"></script>
    <script src="${BASE_FOLDER}/js/gerenteLeadsGauge.js"></script>

    <snk:query var="leadsPorDia">
        SELECT 
            TRUNC(DTCRIACAO) AS Data,
            COUNT(*) AS Total_Leads
        FROM 
            AD_CRMGESINT
        WHERE 
            ORIGEM = 'SI'
            AND TIPINT = 'SO'
            AND TRUNC(DTCRIACAO) BETWEEN TRUNC(:PERIODO.INI) AND TRUNC(:PERIODO.FIN)
        GROUP BY 
            TRUNC(DTCRIACAO)
        ORDER BY 
            TRUNC(DTCRIACAO)

    </snk:query>


    <snk:query var="leadsPorGerente">
        SELECT  
            RK.RANKING,
            RK.GERENTE,
            RK.EFICIENCIA

            FROM VW_RANKEFIC_DCCO RK
            ORDER BY RK.RANKING
    </snk:query>

   <!-- gRAFICO hIGHCHARTS -->
    <script type="text/javascript">
    document.addEventListener('DOMContentLoaded', function () {
        Highcharts.chart('chart_div', {
            chart: {
                type: 'area',  // Alterado para área para um visual mais suave
                zooming: {
                    type: 'x'  // Zoom ao arrastar
                }
            },
            title: {
                text: 'Total de Leads por Dia',
                align: 'left'
            },
            subtitle: {
                text: document.ontouchstart === undefined ?
                    'Clique e arraste para aplicar zoom' :
                    'Faça o movimento de pinça para aplicar zoom',
                align: 'left'
            },
            xAxis: {
                type: 'datetime',  // Tipo de dado de tempo
                title: {
                    text: 'Data'
                }
            },
            yAxis: {
                title: {
                    text: 'Total de Leads'
                }
            },
            legend: {
                enabled: false  // Desabilita a legenda, já que só há uma série
            },
            plotOptions: {
                area: {
                    marker: {
                        radius: 3  // Marcadores menores
                    },
                    lineWidth: 2,  // Linha mais fina
                    color: {
                        linearGradient: {
                            x1: 0,
                            y1: 0,
                            x2: 0,
                            y2: 1
                        },
                        stops: [
                            [0, 'rgb(199, 113, 243)'],  // Cor superior do gradiente
                            [0.7, 'rgb(76, 175, 254)']  // Cor inferior do gradiente
                        ]
                    },
                    states: {
                        hover: {
                            lineWidth: 2  // Espessura da linha ao passar o mouse
                        }
                    },
                    threshold: null  // Permite que a área seja desenhada sem limite
                }
            },
            series: [{
                type: 'area',
                name: 'Leads',
                data: [
                    <c:forEach var="row" items="${leadsPorDia.rows}">
                        [Date.UTC(${row.Data.year}, ${row.Data.month}, ${row.Data.date}), ${row.Total_Leads}],
                    </c:forEach>
                ]
            }]
        });
    });
</script>
<script type="text/javascript">
    document.addEventListener('DOMContentLoaded', function () {
        Highcharts.chart('ranking_eficiencia_chart', {
            chart: {
                type: 'column' // Alterado para 'column'
            },
            title: {
                text: 'Ranking de Eficiência dos Gerentes'
            },
            xAxis: {
                categories: [
                    <c:forEach var="row" items="${leadsPorGerente.rows}">
                        '${row.GERENTE}',
                    </c:forEach>
                ]
            },
            credits: {
                enabled: false
            },
            plotOptions: {
                column: {
                    borderRadius: '25%' 
                },
                series: {
                    dataLabels: {
                        enabled: true,
                        format: '{y:.1f}%' 
                    }
                }
            },
            series: [{
                name: 'Eficiência',
                data: [
                    <c:forEach var="row" items="${leadsPorGerente.rows}">
                        ${row.EFICIENCIA},
                    </c:forEach>
                ]
            }]
        });
    });
    </script>

<script>
    function carregarLeadStatus(statusLead = 'AB') {
         const parametros = { 'STATUSLEAD': statusLead };
        openLevel('lvl_aykicqw', parametros);
    }


    function carregarTodos() {
        const parametros = {'STATUSLEAD' : 'AB'};
        openLevel('lvl_aykicqw');
   }
   
   function carregarLeadDepartamento(departamentoLead = 'MA') {
       const parametros = {'DEPARTAMENTO' : departamentoLead};
       openLevel('lvl_aykicqw', parametros); //Trocar o nome do level
   }


</script>


    <snk:load/> <!-- essa tag deve ficar nesta posição -->    
</head>
<body>

    

    <snk:query var="leadsPorDepartamento">
        SELECT
    DEPTO,     
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
    COUNT(CASE WHEN STATUS = 'FE' THEN 1 END) AS Total_Fechados,
    NVL(SUM(CASE WHEN STATUS = 'AB' AND SYSDATE > DTCRIACAO + TEMPORET THEN 1 ELSE 0 END), 0) AS Total_Abertos_Atrasados
FROM 
    AD_CRMGESINT
WHERE 
    ORIGEM = 'SI' 
    AND TIPINT = 'SO'
    AND TRUNC(DTCRIACAO) BETWEEN TRUNC(:PERIODO.INI) AND TRUNC(:PERIODO.FIN)
GROUP BY
    DEPTO,
    CASE 
        WHEN TO_CHAR(DEPTO) = 'GE' THEN 'Geradores'
        WHEN TO_CHAR(DEPTO) = 'MA' THEN 'Maquinas'
        WHEN TO_CHAR(DEPTO) = 'PE' THEN 'Peças'
        WHEN TO_CHAR(DEPTO) = 'RE' THEN 'Locação'
        WHEN TO_CHAR(DEPTO) = 'SE' THEN 'Serviços'
        WHEN TO_CHAR(DEPTO) = 'SO' THEN 'Solar'
        ELSE 'Sem Depto Definido'
    END
ORDER BY 
    Departamento
    </snk:query>

    

    <snk:query var="leadSPorEmpresa">
        SELECT
        E.CODEMP,
        E.NOMEFANTASIA,
        COUNT(*) AS Total_Leads,
        COUNT(CASE WHEN A.STATUS = 'AB' THEN 1 END) AS Total_Abertos,
        COUNT(CASE WHEN A.STATUS = 'FE' THEN 1 END) AS Total_Fechados,
        NVL(SUM(CASE WHEN A.STATUS = 'AB' AND SYSDATE > A.DTCRIACAO + A.TEMPORET THEN 1 ELSE 0 END), 0) AS Total_Abertos_Atrasados
    FROM 
        AD_CRMGESINT A
        INNER JOIN TSIEMP E ON A.CODEMP = E.CODEMP -- Junção com a tabela de empresas
    WHERE 
        A.ORIGEM = 'SI' 
        AND A.TIPINT = 'SO'
        AND TRUNC(A.DTCRIACAO) BETWEEN TRUNC(:PERIODO.INI) AND TRUNC(:PERIODO.FIN) -- Filtro por período
    GROUP BY
        E.CODEMP,
        E.NOMEFANTASIA
    ORDER BY 
        E.CODEMP
    </snk:query>


    <snk:query var="totalLeadsPorPeriodo">
        SELECT 
            COUNT(*) AS Total_Leads,  
            NVL(SUM(CASE WHEN STATUS = 'AB' THEN 1 ELSE 0 END), 0) AS Total_Abertos,
            NVL(SUM(CASE WHEN STATUS = 'FE' THEN 1 ELSE 0 END), 0) AS Total_Fechados,
            NVL(ROUND(AVG(CASE WHEN DTENCERRAMENTO IS NOT NULL THEN DTENCERRAMENTO - DTCRIACAO END)), 0) AS Tempo_Medio_Encerramento_Dias,
            NVL(ROUND(AVG(CASE WHEN DTENCERRAMENTO IS NOT NULL AND DTENCERRAMENTO > DTCRIACAO + TEMPORET THEN DTENCERRAMENTO - (DTCRIACAO + TEMPORET) END)), 0) AS Media_Dias_Atraso,  -- Removi a vírgula extra
            NVL(SUM(CASE WHEN STATUS = 'AB' AND SYSDATE > DTCRIACAO + TEMPORET THEN 1 ELSE 0 END), 0) AS Total_Abertos_Atrasados,
            NVL(ROUND(AVG(CASE WHEN STATUS = 'AB' AND SYSDATE > DTCRIACAO + TEMPORET THEN SYSDATE - (DTCRIACAO + TEMPORET) END)), 0) AS Media_Dias_Atraso_Leads_Abertos,
            TO_CHAR(:PERIODO.INI, 'DD/MM/YYYY') AS DATAINICIO,  -- Formata DATAINICIO
            TO_CHAR(:PERIODO.FIN, 'DD/MM/YYYY') AS DATAFINAL  -- Formata DATAFINAL
        FROM 
            AD_CRMGESINT
        WHERE 
            ORIGEM = 'SI' 
            AND TIPINT = 'SO'
            AND TRUNC(DTCRIACAO) BETWEEN TRUNC(:PERIODO.INI) AND TRUNC(:PERIODO.FIN)
    </snk:query>

    <div class="container-fluid text-bg-dark">
        
            <div class="row">
                <div class="col-md-12">
                    <h5 class="text-center"> Leads entre o PerÍodo ${totalLeadsPorPeriodo.rows[0].DATAINICIO} - ${totalLeadsPorPeriodo.rows[0].DATAFINAL} </h5>
                </div>
            </div>

            <c:set var="firstRow" value="${totalLeadsPorPeriodo.rows[0]}" />

            <div class="row">
                <div class="col-md-1" onclick="carregarTodos()">
                    <div class="card text-bg-success mb-3 " style="max-width: 18rem;">
                        <div class="card-header text-center">Leads</div>
                        <div class="card-body">
                            <h3 class="card-title text-center">${firstRow.Total_Leads}</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-1" onclick="carregarLeadStatus('AB')">
                    <div class="card text-bg-success mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Aberto</div>
                        <div class="card-body">
                            <h3 class="card-title text-center">${firstRow.Total_Abertos}</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-1" onclick="carregarLeadStatus('FE')">
                    <div class="card text-bg-success mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Fechado</div>
                        <div class="card-body">
                            <h3 class="card-title text-center">${firstRow.Total_Fechados}</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="card text-bg-secondary mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Tempo Medio Resposta</div>
                        <div class="card-body">
                            <h3 class="card-title text-center">${firstRow.Tempo_Medio_Encerramento_Dias}</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="card text-bg-secondary mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Media Dias Atrasos - Fechados</div>
                        <div class="card-body">
                            <h3 class="card-title text-center">${firstRow.Media_Dias_Atraso}</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="card text-bg-danger mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Abertos Atrasados</div>
                        <div class="card-body">
                            <h3 class="card-title text-center">${firstRow.Total_Abertos_Atrasados}</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="card text-bg-danger mb-3" style="max-width: 18rem;">
                        <div class="card-header text-center">Media Dias Atraso - Abertos</div>
                        <div class="card-body">
                            <h3 class="card-title text-center">${firstRow.Media_Dias_Atraso_Leads_Abertos}</h3>
                        </div>
                    </div>
                </div>
            </div>
        

        <div class="row mt-4">
            
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
                                    <th>Abertos e Atrasados</th>
                                    <th>Detalhes</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${leadsPorDepartamento.rows}" var="row"> 
                                    <tr>
                                        <td><c:out value="${row.Departamento}" /></td>
                                        <td><c:out value="${row.Total_Leads}" /></td>
                                        <td><c:out value="${row.Total_Abertos}" /></td>
                                        <td><c:out value="${row.Total_Fechados}" /></td>
                                        <td><c:out value="${row.Total_Abertos_Atrasados}" /></td>
                                        <td>
                                            <!-- Ícone que chama a função carregarLeadDepartamento com o departamento -->
                                            <a href="javascript:void(0);" onclick="carregarLeadDepartamento('${row.DEPTO}');" class="btn btn-link">
                                                <i class="fas fa-arrow-circle-right"></i> <!-- Ícone elegante -->
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">Ranking de Eficiência Gerente</div>
                    <div class="card-body">
                        <div id="ranking_eficiencia_chart"></div> 
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
                    <div class="card-header">Leads por Empresa</div>
                    <div class="card-body">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Empresa</th>
                                    <th>Total</th>
                                    <th>Abertos</th>
                                    <th>Fechados</th>
                                    <th>Abertos e Atrasados</th>
                                    <th>Detalhes</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${leadSPorEmpresa.rows}" var="row"> 
                                    <tr>
                                        <td><c:out value="${row.NOMEFANTASIA}" /></td>
                                        <td><c:out value="${row.Total_Leads}" /></td>
                                        <td><c:out value="${row.Total_Abertos}" /></td>
                                        <td><c:out value="${row.Total_Fechados}" /></td>
                                        <td><c:out value="${row.Total_Abertos_Atrasados}" /></td>
                                        <td>
                                            <!-- Ícone que chama a função carregarLeadDepartamento com o departamento -->
                                            <a href="javascript:void(0);" onclick="carregarLeadEmpresa('${row.CODEMP}');" class="btn btn-link">
                                                <i class="fas fa-arrow-circle-right"></i> <!-- Ícone elegante -->
                                            </a>
                                        </td>
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