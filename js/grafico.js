google.charts.load('current', {'packages':['corechart']});
google.charts.setOnLoadCallback(drawChart);

function drawChart() {
    var data = google.visualization.arrayToDataTable([   

        ['Mes', 'Abertos', 'Fechados'],
        ['Janeiro',  1000,      400],
        ['Fevereiro',  1170,      460],
        ['Marco',  660,       1120],
        ['Abril',  1030,      540],

        ['Maio',  1032,      877],
        ['Junho',  755,      740],
        ['Julho',  240,       120],
        ['Agosto',  780,      320],

        ['Setembro',  55,      51],
        ['Outubro',  0,      0],
        ['Novembro',  0,       0],
        ['Dezembro',  0,      0],

    ]);

    // Array com os nomes de todos os meses
    var meses = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];


    var options = {
        title: 'Leads por Periodo',
        legend: { position: 'bottom' },
        hAxis: {
            title: 'Mês',
            // Define os ticks com base no array de meses
            ticks: meses.map(function(mes) {
                return {v: mes, f: mes}; 
            })
        },
        vAxis: {
            title: 'Quantidade de Leads',
            // Formata os valores para números inteiros
            format: '0',
            // Define o valor mínimo como zero para remover valores negativos
            viewWindow: {
                min: 0
            }
        }
    };

    var chart = new google.visualization.LineChart(document.getElementById('chart_div'));

    chart.draw(data, options);   

}