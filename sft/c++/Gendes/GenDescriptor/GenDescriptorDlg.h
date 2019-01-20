// GenDescriptorDlg.h
// Author: hyan23
// Date: 2016.06.02
//

#pragma once

class CGenDescriptorDlg : public CDialogEx {
public:
	CGenDescriptorDlg(CWnd* pParent = NULL); // 标准构造函数

// 对话框数据
	enum { IDD = IDD_GENDESCRIPTOR_DIALOG };

protected:
	virtual void DoDataExchange(CDataExchange* pDX); // DDX/DDV 支持

protected:
	HICON m_hIcon;

	// 生成的消息映射函数
	virtual BOOL OnInitDialog(void);
	afx_msg void OnPaint(void);
	afx_msg HCURSOR OnQueryDragIcon(void);
	DECLARE_MESSAGE_MAP()

private:
	BOOL blG;		// 粒度
	BOOL blBD;		// 上部边界
	BOOL blL;		// 64-bit
	BOOL blAVL;		// 保留的
	BOOL blP;		// 存在
	BOOL blTypeX;	// 执行
	BOOL blTypeCE;	// 扩展方向/依从代码
	BOOL blTypeRW;	// 可读/可写
	BOOL blTypeA;	// 已访问
	BOOL blPrivilege1; // 特权级
	BOOL blPrivilege0; // 特权级

	int iRadio;		// 主类型

	CString strBase;	// 线性基地址
	CString strLimit;	// 段界限
	CString strText;

	unsigned iUPPER, iLower; // 结果

	afx_msg void OnBnClickedOk(void);
	afx_msg void OnBnClickedButton0(void);
};
