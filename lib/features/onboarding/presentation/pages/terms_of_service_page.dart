import 'package:flutter/material.dart';
import '../../../../core/constants/color_palette.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Termos de Uso',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TERMOS DE USO E POLÍTICA DE PRIVACIDADE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aplicativo Merculy',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMedium,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              '1. ACEITAÇÃO DOS TERMOS',
              'Ao acessar e utilizar o aplicativo Merculy, você concorda em ficar vinculado a estes Termos de Uso e à nossa Política de Privacidade. Se você não concordar com algum destes termos, não utilize nossos serviços.\n\nEste documento está em conformidade com a Lei Geral de Proteção de Dados (LGPD - Lei 13.709/2018) e demais regulamentações brasileiras aplicáveis.',
            ),
            
            _buildSection(
              '2. DESCRIÇÃO DO SERVIÇO',
              'O Merculy é um aplicativo de newsletters personalizadas que utiliza inteligência artificial para:\n\n• Gerar newsletters customizadas baseadas nos seus interesses\n• Analisar viés político de artigos e fontes jornalísticas\n• Organizar conteúdo por tópicos de interesse\n• Fornecer análises de distribuição política das fontes\n• Permitir acesso direto às fontes originais dos artigos\n• Gerenciar preferências de entrega e formato de conteúdo',
            ),
            
            _buildSection(
              '3. COLETA E TRATAMENTO DE DADOS PESSOAIS',
              '3.1. DADOS COLETADOS\nColetamos as seguintes categorias de dados pessoais:\n\n• Dados de identificação: nome, e-mail\n• Dados de autenticação: senhas criptografadas, tokens de acesso\n• Dados de perfil do Google (quando utilizar login social)\n• Preferências de interesse e tópicos selecionados\n• Configurações de entrega (dias, horários, formato)\n• Canais e fontes seguidas\n• Histórico de newsletters geradas e salvas\n• Dados de cache de imagens para otimização de performance\n\n3.2. FINALIDADES DO TRATAMENTO\nUtilizamos seus dados para:\n\n• Autenticação e controle de acesso\n• Personalização de newsletters\n• Análise de preferências de conteúdo\n• Otimização da experiência do usuário\n• Cumprimento de obrigações legais\n• Melhoria dos algoritmos de recomendação',
            ),
            
            _buildSection(
              '4. BASE LEGAL PARA TRATAMENTO',
              'O tratamento dos seus dados pessoais é realizado com base nas seguintes hipóteses legais previstas na LGPD:\n\n• Consentimento: para coleta de preferências e interesses\n• Execução de contrato: para fornecimento dos serviços contratados\n• Interesse legítimo: para análise de uso e melhoria dos serviços\n• Cumprimento de obrigação legal: quando exigido por lei',
            ),
            
            _buildSection(
              '5. ARMAZENAMENTO E SEGURANÇA',
              '5.1. ARMAZENAMENTO LOCAL\nAlguns dados são armazenados localmente em seu dispositivo para manter sessão ativa (tokens de autenticação)\n\n5.2. MEDIDAS DE SEGURANÇA\nImplementamos as seguintes medidas de segurança:\n\n• Criptografia de senhas e dados sensíveis\n• Tokens JWT para autenticação segura\n• Comunicação via HTTPS\n• Controle de acesso baseado em autenticação\n• Armazenamento seguro em dispositivos móveis',
            ),
            
            _buildSection(
              '6. COMPARTILHAMENTO DE DADOS',
              'Não vendemos, alugamos ou compartilhamos seus dados pessoais com terceiros, exceto:\n\n• Quando expressamente autorizado por você\n• Para cumprimento de obrigações legais\n• Para proteção de direitos, propriedade ou segurança\n• Com prestadores de serviços essenciais (sob acordos de confidencialidade)\n\nQuando utilizamos serviços do Google (Google Sign-In), os dados são tratados conforme as políticas de privacidade do Google.',
            ),
            
            _buildSection(
              '7. SEUS DIREITOS COMO TITULAR',
              'Conforme a LGPD, você possui os seguintes direitos:\n\n• Confirmação da existência de tratamento de dados\n• Acesso aos seus dados pessoais\n• Correção de dados incompletos, inexatos ou desatualizados\n• Anonimização, bloqueio ou eliminação de dados\n• Portabilidade dos dados\n• Eliminação dos dados tratados com base no consentimento\n• Informação sobre compartilhamento de dados\n• Revogação do consentimento',
            ),
            
            _buildSection(
              '8. RETENÇÃO DE DADOS',
              'Seus dados pessoais serão mantidos pelo tempo necessário para:\n\n• Cumprimento das finalidades informadas\n• Atendimento de obrigações legais\n• Exercício regular de direitos\n\nApós esse período, os dados serão eliminados ou anonimizados, salvo quando a manutenção for exigida por lei.',
            ),
            
            _buildSection(
              '9. COOKIES E TECNOLOGIAS SIMILARES',
              'Utilizamos tecnologias de cache e armazenamento local para:\n\n• Melhorar a performance do aplicativo\n• Manter preferências do usuário\n• Otimizar carregamento de imagens\n• Manter sessão ativa\n\nVocê pode gerenciar essas configurações através das opções do aplicativo.',
            ),
            
            _buildSection(
              '10. MENORES DE IDADE',
              'Nossos serviços não são direcionados a menores de 18 anos. Não coletamos intencionalmente dados pessoais de menores.',
            ),
            
            _buildSection(
              '11. ALTERAÇÕES NOS TERMOS',
              'Podemos atualizar estes Termos de Uso periodicamente. Alterações significativas serão comunicadas através do aplicativo ou por e-mail. O uso continuado dos serviços após as alterações constituirá aceitação dos novos termos.',
            ),
            
            _buildSection(
              '12. LEGISLAÇÃO APLICÁVEL',
              'Estes Termos de Uso são regidos pela legislação brasileira, especialmente:\n\n• Lei Geral de Proteção de Dados (LGPD - Lei 13.709/2018)\n• Marco Civil da Internet (Lei 12.965/2014)\n• Código de Defesa do Consumidor (Lei 8.078/1990)\n\nQualquer disputa será dirimida pelos tribunais brasileiros.',
            ),
            
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Última atualização: 17 de setembro de 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Este documento está em conformidade com a LGPD e demais regulamentações brasileiras aplicáveis.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMedium,
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}